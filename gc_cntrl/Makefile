VCOM_ARGS=-novopt -O0 -check_synthesis -2008 -work work -suppress 1236
VSIM_ARGS=-novopt -nowlflock -msgmode both

VHDL_FILES = \
	../math/src/math_pkg.vhd\
	./src/gc_cntrl_pkg.vhd\
	../synchronizer/src/sync_pkg.vhd\
	../synchronizer/src/sync.vhd\
	./src/pulsewidth_encoder.vhd\
	./src/gc_cntrl.vhd
	
TB_FILES = ./tb/gc_cntrl_tb.vhd
TB = gc_cntrl_tb

SIM_TIME = -all
TIME_RESOLUTION = 1ps

all: compile

compile: 
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'

list_sources:
	@for i in $(VHDL_FILES); do \
		echo $$i;\
	done;

sim_gui: compile
	vsim -do "vsim $(TB) $(VSIM_ARGS) -onfinish stop; do tb/wave.do;run $(SIM_TIME)" 


sim: compile
	vsim -c -do "vsim $(TB) $(VSIM_ARGS); run $(SIM_TIME);quit"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work

