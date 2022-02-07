library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gc_cntrl_pkg is

	type gc_cntrl_state_t is record
		btn_up : std_logic;
		btn_down : std_logic;
		btn_left : std_logic;
		btn_right : std_logic;
		btn_a : std_logic;
		btn_b : std_logic;
		btn_x : std_logic;
		btn_y : std_logic;
		btn_z : std_logic;
		btn_start : std_logic;
		btn_l : std_logic;
		btn_r : std_logic;
		-- Joysticks
		joy_x : std_logic_vector(7 downto 0);
		joy_y : std_logic_vector(7 downto 0);
		c_x : std_logic_vector(7 downto 0);
		c_y : std_logic_vector(7 downto 0);
		-- Trigger
		trigger_l : std_logic_vector(7 downto 0);
		trigger_r : std_logic_vector(7 downto 0);
	end record;

	constant GC_BUTTONS_RESET_VALUE : gc_cntrl_state_t := (joy_x => (others => '0'), joy_y => (others => '0'), 
														   c_x => (others => '0'), c_y => (others => '0'), 
														   trigger_l => (others => '0'), trigger_r => (others => '0'), 
														   others => '0');

	component gc_cntrl is
		generic (
			CLK_FREQ : integer := 50000000;
			SYNC_STAGES : integer := 2;
			REFRESH_TIMEOUT : integer := 6000
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;

			-- connection to the controller
			data : inout std_logic;

			-- internal connection
			cntrl_state : out gc_cntrl_state_t
		);
	end component;

	function to_slv (s : gc_cntrl_state_t) return std_logic_vector;
	function to_gc_cntrl_state(slv : std_logic_vector(63 downto 0)) return gc_cntrl_state_t;
end package;

package body gc_cntrl_pkg is
	function to_slv(s : gc_cntrl_state_t) return std_logic_vector is
		variable ret : std_logic_vector(63 downto 0);
	begin
		ret(63 downto 61) := "000";
		ret(60) := s.btn_start;
		ret(59) := s.btn_y;
		ret(58) := s.btn_x;
		ret(57) := s.btn_b;
		ret(56) := s.btn_a;
		ret(55) := '1';
		ret(54) := s.btn_l;
		ret(53) := s.btn_r;
		ret(52) := s.btn_z;
		ret(51) := s.btn_up;
		ret(50) := s.btn_down;
		ret(49) := s.btn_right;
		ret(48) := s.btn_left;
		ret(47 downto 40) := s.joy_x;
		ret(39 downto 32) := s.joy_y;
		ret(31 downto 24) := s.c_x;
		ret(23 downto 16) := s.c_y;
		ret(15 downto 8) := s.trigger_l;
		ret(7 downto 0) := s.trigger_r;
		return ret;
	end function;

	function to_gc_cntrl_state(slv : std_logic_vector(63 downto 0)) return gc_cntrl_state_t is
		variable ret : gc_cntrl_state_t;
	begin
		ret.btn_start := slv(60);
		ret.btn_y := slv(59);
		ret.btn_x := slv(58);
		ret.btn_b := slv(57);
		ret.btn_a := slv(56);
		ret.btn_l := slv(54);
		ret.btn_r := slv(53);
		ret.btn_z := slv(52);
		ret.btn_up := slv(51);
		ret.btn_down := slv(50);
		ret.btn_right := slv(49);
		ret.btn_left := slv(48);
		ret.joy_x := slv(47 downto 40);
		ret.joy_y := slv(39 downto 32);
		ret.c_x := slv(31 downto 24);
		ret.c_y := slv(23 downto 16);
		ret.trigger_l := slv(15 downto 8);
		ret.trigger_r := slv(7 downto 0);
		return ret;
	end function;
end package body;