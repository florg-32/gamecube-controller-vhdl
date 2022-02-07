library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gc_cntrl_pkg.all;

entity gc_cntrl is
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
end entity;

architecture rtl of gc_cntrl is
	constant US_CYCLES : integer := CLK_FREQ/1000000;
	constant TIMEOUT_CYCLES : integer := US_CYCLES*REFRESH_TIMEOUT;

	constant POLL_SEQUENCE : std_logic_vector(0 to 24) := x"400302" & "1";
	
	signal do_send : std_logic;
	signal received_valid : std_logic;
	signal received_data : std_logic_vector(64 downto 0);

	signal button_reg : gc_cntrl_state_t;

	signal refresh_counter : natural range 0 to TIMEOUT_CYCLES+1;
begin

	pwe_inst : entity work.pulsewidth_encoder(rtl)
	generic map (
		ZERO_LOWCYCLES => US_CYCLES*3,
		ONE_LOWCYCLES => US_CYCLES*1,
		WAIT_CYCLES => US_CYCLES*2,
		SYNC_STAGES => SYNC_STAGES
	)
	port map (
		clk => clk,
		res_n => res_n,
		data => data,
		send_data_len => 25,
		send_data => POLL_SEQUENCE,
		do_send => do_send,
		received_valid => received_valid,
		received_data_len => open,
		received_data => received_data
	);

	sync : process(res_n, clk)
	begin
		if res_n = '0' then
			do_send <= '0';
			refresh_counter <= TIMEOUT_CYCLES;
			button_reg <= GC_BUTTONS_RESET_VALUE;
		elsif rising_edge(clk) then
			refresh_counter <= refresh_counter + 1; 
			do_send <= '0';

			if refresh_counter = TIMEOUT_CYCLES then
				refresh_counter <= 0;
				do_send <= '1';
			end if;

			if received_valid = '1' then
				button_reg <= to_gc_cntrl_state(received_data(64 downto 1));
			end if;
		end if;
	end process;
	
	cntrl_state <= button_reg;
end architecture;