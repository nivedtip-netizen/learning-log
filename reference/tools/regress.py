#!/usr/bin/env python3
"""Seed regression runner with an HTML dashboard.

Reads a JSON config (see ../p3.3-axi4lite/regress.json), builds once, then runs
every test x seed in parallel. Each log is judged by:
  * "RESULT: PASS" / "RESULT: FAIL"  (plain Verilog/SV benches in this repo), or
  * the UVM report summary: UVM_ERROR / UVM_FATAL counts (UVM benches).
Coverage is read from "COVERAGE: 87.5%" or "coverage = 87.5%".
Failures are bucketed by their first error line with numbers masked, so 40
failing seeds with the same root cause show up as one bucket.

Usage:
  python3 regress.py CONFIG.json [--seeds 20] [--jobs 8] [--html dashboard.html]
"""
import argparse
import concurrent.futures as cf
import datetime as dt
import html
import json
import os
import re
import subprocess
import sys
import time

ERR_PATTERNS = [r"UVM_(ERROR|FATAL)\s*(?!:\s*\d)", r"\bERR\b", r"\bERROR\b", r"Assertion failed", r"MISMATCH"]


def judge(text):
    """Return (status, coverage or None, first_error_line or '')."""
    cov = None
    m = re.findall(r"(?:COVERAGE:|coverage\s*=)\s*([0-9.]+)\s*%", text, re.I)
    if m:
        cov = float(m[-1])
    first_err = ""
    for line in text.splitlines():
        if any(re.search(p, line) for p in ERR_PATTERNS):
            first_err = line.strip()
            break
    res = re.findall(r"RESULT:\s*(PASS|FAIL)", text)
    if res and not first_err:
        m2 = re.findall(r"RESULT:.*", text)
        first_err = m2[-1].strip() if res[-1] == "FAIL" else ""
    if res:
        return res[-1], cov, first_err
    uvm_err = re.search(r"UVM_ERROR\s*:\s*(\d+)", text)
    uvm_fat = re.search(r"UVM_FATAL\s*:\s*(\d+)", text)
    if uvm_err and uvm_fat:
        ok = int(uvm_err.group(1)) == 0 and int(uvm_fat.group(1)) == 0
        return ("PASS" if ok else "FAIL"), cov, first_err
    return "CRASH", cov, first_err or "no RESULT line and no UVM report summary"


def bucket_key(line):
    line = re.sub(r"\[\s*\d+\]|@\s*[0-9a-fA-F]+|0x[0-9a-fA-F]+|\b(?=[0-9a-fA-F]*\d)[0-9a-fA-F]+(ps|ns)?\b", "#", line)
    return re.sub(r"\s+", " ", line)[:140]


def run_one(test, seed, workdir, logdir, timeout):
    cmd = test["cmd"].format(seed=seed)
    log = os.path.join(logdir, f"{test['name']}_s{seed}.log")
    t0 = time.time()
    try:
        p = subprocess.run(cmd, shell=True, cwd=workdir, capture_output=True, text=True, timeout=timeout)
        out = p.stdout + p.stderr
    except subprocess.TimeoutExpired:
        out = "TIMEOUT"
    with open(log, "w") as f:
        f.write(f"$ {cmd}\n{out}")
    status, cov, err = judge(out)
    if out == "TIMEOUT":
        status, err = "CRASH", "timeout"
    return dict(test=test["name"], seed=seed, status=status, cov=cov, err=err, log=log, secs=time.time() - t0)


def write_html(path, title, results, tests, seeds, buckets):
    color = {"PASS": "#1a7f37", "FAIL": "#cf222e", "CRASH": "#9a6700"}
    by = {(r["test"], r["seed"]): r for r in results}
    rows = []
    for t in tests:
        cells = []
        covs = [by[(t, s)]["cov"] for s in seeds if by[(t, s)]["cov"] is not None]
        for s in seeds:
            r = by[(t, s)]
            tip = html.escape(f"seed {s}: {r['status']}" + (f", coverage {r['cov']}%" if r["cov"] is not None else "") +
                              (f"\n{r['err']}" if r["status"] != "PASS" else ""))
            rel = os.path.relpath(r["log"], os.path.dirname(os.path.abspath(path)))
            cells.append(f'<td><a href="{html.escape(rel)}" title="{tip}" class="c" style="background:{color[r["status"]]}">'
                         f'{s}</a></td>')
        npass = sum(by[(t, s)]["status"] == "PASS" for s in seeds)
        cov_txt = f"{max(covs):.1f}% (min {min(covs):.1f}%)" if covs else "n/a"
        rows.append(f"<tr><th>{html.escape(t)}</th><td>{npass}/{len(seeds)}</td><td>{cov_txt}</td>{''.join(cells)}</tr>")
    total = len(results)
    npass = sum(r["status"] == "PASS" for r in results)
    bucket_rows = "".join(
        f"<tr><td>{len(v)}</td><td><code>{html.escape(k)}</code></td>"
        f"<td>{html.escape(', '.join(sorted({r['test'] for r in v})))}</td>"
        f"<td>{html.escape(', '.join(str(r['seed']) for r in v[:12]))}{' ...' if len(v) > 12 else ''}</td></tr>"
        for k, v in sorted(buckets.items(), key=lambda kv: -len(kv[1])))
    doc = f"""<!doctype html><html><head><meta charset="utf-8"><title>{html.escape(title)}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
 body{{font-family:system-ui,sans-serif;margin:24px;color:#1f2328;background:#fff}}
 table{{border-collapse:collapse;margin:12px 0}} th,td{{padding:4px 8px;border-bottom:1px solid #d0d7de;text-align:left}}
 .c{{display:inline-block;min-width:22px;text-align:center;color:#fff;border-radius:4px;text-decoration:none;font-size:12px}}
 .kpi{{display:inline-block;margin-right:28px}} .kpi b{{font-size:28px;display:block}}
 @media (prefers-color-scheme: dark){{body{{background:#0d1117;color:#e6edf3}} th,td{{border-color:#30363d}}}}
</style></head><body>
<h1>{html.escape(title)}</h1>
<p>{dt.datetime.now():%Y-%m-%d %H:%M} &middot; {len(tests)} tests &times; {len(seeds)} seeds</p>
<div class="kpi"><b>{npass}/{total}</b>runs passed</div>
<div class="kpi"><b>{len(buckets)}</b>failure buckets</div>
<h2>Pass/fail per seed</h2>
<table><tr><th>test</th><th>passed</th><th>coverage</th><th colspan="{len(seeds)}">seeds (click for log)</th></tr>
{''.join(rows)}</table>
<h2>Failure buckets</h2>
{"<p>None.</p>" if not buckets else f"<table><tr><th>runs</th><th>first error (numbers masked)</th><th>tests</th><th>seeds</th></tr>{bucket_rows}</table>"}
</body></html>"""
    with open(path, "w") as f:
        f.write(doc)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("config")
    ap.add_argument("--seeds", type=int, default=None)
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    ap.add_argument("--html", default=None)
    a = ap.parse_args()
    cfg = json.load(open(a.config))
    workdir = os.path.dirname(os.path.abspath(a.config))
    nseeds = a.seeds or cfg.get("seeds", 10)
    seeds = list(range(1, nseeds + 1))
    logdir = os.path.join(workdir, cfg.get("logdir", "logs"))
    os.makedirs(logdir, exist_ok=True)
    for b in cfg.get("build", []):
        print(f"build: {b}")
        if subprocess.run(b, shell=True, cwd=workdir).returncode != 0:
            sys.exit("build failed")
    jobs = [(t, s) for t in cfg["tests"] for s in seeds]
    with cf.ThreadPoolExecutor(max_workers=a.jobs) as ex:
        results = list(ex.map(lambda ts: run_one(ts[0], ts[1], workdir, logdir, cfg.get("timeout", 600)), jobs))
    buckets = {}
    for r in results:
        if r["status"] != "PASS":
            buckets.setdefault(bucket_key(r["err"] or r["status"]), []).append(r)
    tests = [t["name"] for t in cfg["tests"]]
    print(f"\n{'test':<22}{'pass':>8}{'coverage':>12}")
    for t in tests:
        rs = [r for r in results if r["test"] == t]
        covs = [r["cov"] for r in rs if r["cov"] is not None]
        print(f"{t:<22}{sum(r['status'] == 'PASS' for r in rs):>4}/{len(rs):<3}{(f'{max(covs):.1f}%' if covs else 'n/a'):>12}")
    if buckets:
        print("\nfailure buckets:")
        for k, v in sorted(buckets.items(), key=lambda kv: -len(kv[1])):
            print(f"  {len(v):>4} x {k}")
    html_path = os.path.join(workdir, a.html or cfg.get("html", "dashboard.html"))
    write_html(html_path, cfg.get("title", "Regression"), results, tests, seeds, buckets)
    print(f"\ndashboard: {html_path}")
    sys.exit(0 if not buckets else 1)


if __name__ == "__main__":
    main()
