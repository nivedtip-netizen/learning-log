# P5.1 formal FIFO.  Runs with plain Yosys (sat -tempinduct); fifo.sby is the SymbiYosys version.
#   make prove   clean FIFO: BMC + k-induction at DEPTH 4 and 16 (expect SUCCESS)
#   make bug     BUG_RARE FIFO: formal finds the shortest failing trace (expect FAIL)
#   make sim     the same bug against constrained-random simulation, short and long runs
DEFS  ?=
DEPTH ?= 4
YS = read_verilog -formal -DFORMAL -DNO_COVER $(DEFS) -I formal rtl/sync_fifo.v; \
     chparam -set DEPTH $(DEPTH) sync_fifo; prep -top sync_fifo; memory; async2sync; opt_clean; \
     sat -tempinduct -prove-asserts -set-assumes -set-init-zero -seq 1 -maxsteps 40 -show-public

all: prove bug sim

formal_one:
	@mkdir -p logs
	@yosys -l logs/formal_$(TAG)_d$(DEPTH).log -p "$(YS)" > /dev/null 2>&1 || true
	@printf "%-6s DEPTH=%-3s %s\n" $(TAG) $(DEPTH) "$$(grep -E 'SUCCESS|model found' logs/formal_$(TAG)_d$(DEPTH).log | tail -1)"

prove:
	@$(MAKE) -s formal_one TAG=clean DEPTH=4
	@$(MAKE) -s formal_one TAG=clean DEPTH=16

bug:
	@$(MAKE) -s formal_one TAG=bug DEPTH=4  DEFS=-DBUG_RARE
	@$(MAKE) -s formal_one TAG=bug DEPTH=16 DEFS=-DBUG_RARE

sim_one:
	@mkdir -p logs
	@iverilog -g2012 $(DEFS) -P tb_rand.DEPTH=$(DEPTH) -P tb_rand.LEN=$(LEN) -o logs/rand.out tb/tb_rand.v rtl/sync_fifo.v
	@printf "%-6s DEPTH=%-3s LEN=%-5s %s\n" $(TAG) $(DEPTH) $(LEN) "$$(vvp -n logs/rand.out +SEED=$(or $(SEED),1) | grep -E 'runs=|RESULT' | tr '\n' ' ')"

sim:
	@$(MAKE) -s sim_one TAG=clean DEPTH=16 LEN=200
	@$(MAKE) -s sim_one TAG=bug   DEPTH=4  LEN=20  DEFS=-DBUG_RARE
	@$(MAKE) -s sim_one TAG=bug   DEPTH=16 LEN=20  DEFS=-DBUG_RARE
	@$(MAKE) -s sim_one TAG=bug   DEPTH=16 LEN=200 DEFS=-DBUG_RARE

clean:
	rm -rf logs

.PHONY: all formal_one prove bug sim_one sim clean
