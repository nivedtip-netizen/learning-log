# P3.2: UVM and RAL for the APB block

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

UVM environment for the P2.4 APB block: agent with a config object, driver, monitor; scoreboard and
coverage subscriber on analysis ports; a hand-written register model (8 `uvm_reg` classes including
W1C, RO and WO fields), adapter and explicit `uvm_reg_predictor`; tests: hardware reset, bit bash,
random read/write with mirror check, W1C, bad address, wait-state stress.

## Run (needs a UVM simulator)
```
<simulator> -f files.f +UVM_TESTNAME=apb_rw_test
python3 ../tools/regress.py regress.json        # regress.json has Questa-style commands
```

## Results
- **Not run here** (no UVM simulator in this environment).
- The same Python regression script was run on the APB Icarus bench instead: 4 tests x 5 seeds PASS, HTML dashboard produced.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Run on EDA Playground; check that the W1C field's mirror is right after a clear.
