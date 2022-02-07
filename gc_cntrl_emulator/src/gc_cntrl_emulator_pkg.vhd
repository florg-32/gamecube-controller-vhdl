library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gc_cntrl_pkg.all;

package gc_cntrl_emulator_pkg is
	component gc_cntrl_emulator is
		generic (
			CLK_FREQ : integer := 50000000;
			SYNC_STAGES : integer := 2
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			data : inout std_logic;
			button_state : in gc_cntrl_state_t;
			rumble : out std_logic
		);
	end component;
end package;
