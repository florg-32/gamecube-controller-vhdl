# gamecube-controller-vhdl
A simple module to handle a gamecube controller on a FPGA. The gc_cntrl folder contains a fully synthesizable entity, which can be connected to a gamecube controllers data line.
It will automatically poll the controllers state with the given rate. Testbenches and Makefiles (QuestaSim) to use them are included.
