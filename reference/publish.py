#!/usr/bin/env python3
"""Put the reference projects into my learning-log repo, file the bug issues, commit, push.

Run in WSL after unzipping the bundle somewhere (for example ~/reference-bundle):

    python3 ~/reference-bundle/reference/publish.py --repo /mnt/c/Users/l/learning-log --dry-run
    python3 ~/reference-bundle/reference/publish.py --repo /mnt/c/Users/l/learning-log

What it does, in order (it stops and asks before the push):
  1. checks the repo: it is learning-log, its tracked files have no uncommitted changes
  2. copies reference/, .github/ and resume/ from the bundle into the repo (no build outputs)
  3. if the GitHub CLI is logged in: creates one issue per bug in reference/issues/issues.json
     (skips any issue whose title already exists), labelled "bug"
  4. one commit per project folder; the commit message says "Fixes #N" for that folder's issues,
     so GitHub closes each issue and links it to the commit when it reaches main
  5. asks, then pushes the current branch

Never touches any other repository.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys

BUNDLE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))   # folder that holds reference/
SKIP_DIRS = {"logs", "logs_bugs", "rand", "obj_dpi", "obj_sva", "sim_build", "sim_build_vl", "__pycache__"}
SKIP_EXT = (".out", ".vcd", ".fst", ".stat", ".vvp", ".elf", ".bin", ".dis", ".o", ".log")
SKIP_FILES = {"uart_netlist.v", "sim", "rv32i_ref", "results.xml"}
GITIGNORE_ADD = ["", "# reference projects: build and run outputs", "logs/", "logs_bugs/", "rand/", "obj_*/",
                 "sim_build*/", "results.xml", "__pycache__/", "*.out", "*.stat", "*.elf", "*.bin", "*.dis",
                 "*.log", "uart_netlist.v", "reference/**/sim", "reference/**/rv32i_ref", "dashboard*.html"]


def sh(cmd, cwd=None, check=True, capture=True):
    r = subprocess.run(cmd, cwd=cwd, text=True, capture_output=capture)
    if check and r.returncode != 0:
        print("command failed:", " ".join(cmd)); print(r.stdout, r.stderr); sys.exit(1)
    return r


def copy_tree(src, dst, dry):
    n = 0
    for root, dirs, files in os.walk(src):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        rel = os.path.relpath(root, src)
        for f in files:
            if f.endswith(SKIP_EXT) or f in SKIP_FILES or (f.startswith("dashboard") and f.endswith(".html")):
                continue
            s = os.path.join(root, f)
            d = os.path.join(dst, rel, f)
            n += 1
            if not dry:
                os.makedirs(os.path.dirname(d), exist_ok=True)
                shutil.copy2(s, d)
    return n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default="/mnt/c/Users/l/learning-log")
    ap.add_argument("--dry-run", action="store_true", help="show what would happen, change nothing")
    ap.add_argument("--no-issues", action="store_true")
    a = ap.parse_args()
    repo = os.path.abspath(os.path.expanduser(a.repo))

    # ---- 1. safety checks ----
    if "TIP_trainer_in_pocket" in repo:
        sys.exit("refusing: that is not the learning-log repo")
    if not os.path.isdir(os.path.join(repo, ".git")):
        sys.exit(f"{repo} is not a git repository")
    url = sh(["git", "remote", "get-url", "origin"], cwd=repo).stdout.strip()
    if "learning-log" not in url:
        sys.exit(f"origin is {url}, expected the learning-log repo")
    dirty = sh(["git", "status", "--porcelain", "--untracked-files=no"], cwd=repo).stdout.strip()
    if dirty:
        sys.exit("the repo has uncommitted changes to tracked files; commit or stash them first:\n" + dirty)
    branch = sh(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=repo).stdout.strip()
    print(f"repo {repo} ({url}), branch {branch}")
    ahead = sh(["git", "rev-list", "--count", "@{u}..HEAD"], cwd=repo, check=False).stdout.strip()
    if ahead and ahead != "0":
        print(f"note: {ahead} local commit(s) not pushed yet (for example Mini 2); they will be pushed too")

    # ---- 2. copy ----
    for part in ("reference", ".github", "resume"):
        src = os.path.join(BUNDLE, part)
        if os.path.isdir(src):
            n = copy_tree(src, os.path.join(repo, part), a.dry_run)
            print(f"{'would copy' if a.dry_run else 'copied'} {n} files: {part}/")
    gi = os.path.join(repo, ".gitignore")
    old = open(gi).read() if os.path.exists(gi) else ""
    if "# reference projects" not in old and not a.dry_run:
        open(gi, "a").write("\n".join(GITIGNORE_ADD) + "\n")

    # ---- 3. issues ----
    issues = json.load(open(os.path.join(BUNDLE, "reference", "issues", "issues.json")))
    by_project = {}
    gh_ok = (not a.no_issues) and shutil.which("gh") and sh(["gh", "auth", "status"], check=False).returncode == 0
    if not gh_ok:
        print("GitHub CLI not available or not logged in: skipping issues "
              "(install: sudo apt install gh, then: gh auth login). Commits will not say 'Fixes #N'.")
    else:
        if not a.dry_run:
            sh(["gh", "label", "create", "bug", "--color", "d73a4a", "--force"], cwd=repo, check=False)
        for it in issues:
            found = sh(["gh", "issue", "list", "--state", "all", "--search", f'in:title "{it["title"]}"',
                        "--json", "number,title"], cwd=repo, check=False).stdout
            num = None
            try:
                for x in json.loads(found or "[]"):
                    if x["title"] == it["title"]:
                        num = x["number"]
            except json.JSONDecodeError:
                pass
            if num is None and not a.dry_run:
                out = sh(["gh", "issue", "create", "--title", it["title"], "--label", "bug", "--body",
                          it["body"] + "\n\nFound while building the reference implementation (AI-assisted)."],
                         cwd=repo).stdout.strip()
                num = int(out.rstrip("/").split("/")[-1])
                print(f"  created #{num}: {it['title']}")
            elif num is not None:
                print(f"  exists  #{num}: {it['title']}")
            else:
                print(f"  would create: {it['title']}")
            if num is not None:
                by_project.setdefault(it["project"], []).append(num)

    if a.dry_run:
        print("dry run: nothing changed"); return

    # ---- 4. commits, one per project ----
    ref = os.path.join(repo, "reference")
    folders = sorted(d for d in os.listdir(ref) if os.path.isdir(os.path.join(ref, d)) and d not in SKIP_DIRS)
    order = [f for f in folders if f.startswith("mini")] + [f for f in folders if f.startswith("p")]
    order += [f for f in folders if f not in order]
    for f in order:
        sh(["git", "add", os.path.join("reference", f)], cwd=repo)
        if not sh(["git", "diff", "--cached", "--quiet"], cwd=repo, check=False).returncode:
            continue
        msg = f"Reference {f} (AI-assisted, being rebuilt by me)"
        fixes = by_project.get(f, [])
        if fixes:
            msg += "\n\n" + "\n".join(f"Fixes #{n}" for n in fixes)
        sh(["git", "commit", "-q", "-m", msg], cwd=repo)
        print("committed", f, ("fixes " + ", ".join(f"#{n}" for n in fixes)) if fixes else "")
    sh(["git", "add", "reference", ".github", "resume", ".gitignore"], cwd=repo, check=False)
    if sh(["git", "diff", "--cached", "--quiet"], cwd=repo, check=False).returncode:
        sh(["git", "commit", "-q", "-m", "Reference index, CI workflow and resume"], cwd=repo)
        print("committed index, CI and resume")

    # ---- 5. push ----
    print(sh(["git", "log", "--oneline", "@{u}..HEAD"], cwd=repo, check=False).stdout)
    if input(f"push these commits to origin/{branch}? [y/N] ").strip().lower() == "y":
        sh(["git", "push", "-u", "origin", branch], cwd=repo, capture=False)
        print("pushed. Issues close when the 'Fixes #N' commits land on the default branch.")
    else:
        print("not pushed. Run 'git push' yourself when ready.")


if __name__ == "__main__":
    main()
