library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gc_cntrl_pkg.all;

--! This module emulates a simplified gamecube controller. The provided button
--! state can be polled by first sending x"400302"&"1"
entity gc_cntrl_emulator is
	generic (
		CLK_FREQ : integer := 50000000;
		SYNC_STAGES : integer := 2
	);
	port (
		clk : in std_logic;
		res_n : in std_logic;
		data : inout std_logic; --! gamecube data line
		button_state : in gc_cntrl_state_t; --! button state to send
		rumble : out std_logic --! not implemented, stuck at '0'
	);
end entity;

architecture rtl of gc_cntrl_emulator is
	constant US_CYCLES : integer := CLK_FREQ/1000000;
	constant POLL_SEQUENCE : std_logic_vector(0 to 24) := x"400302" & "1";

	signal do_send, received_valid : std_logic;
	signal received_data : std_logic_vector(24 downto 0);
begin
	rumble <= '0'; -- not implemented

	pwe_inst : entity work.pulsewidth_encoder(rtl)
	generic map (
		SEND_DATA_MAXLEN => 65,
		RECV_DATA_MAXLEN => 25,
		ZERO_LOWCYCLES => 3*US_CYCLES,
		ONE_LOWCYCLES => US_CYCLES,
		WAIT_CYCLES => 2*US_CYCLES,
		SYNC_STAGES => SYNC_STAGES
	)
	port map (
		clk => clk,
		res_n => res_n,
		data => data,
		do_send => do_send,
		send_data_len => 65,
		send_data => to_slv(button_state) & "1",
		received_valid => received_valid,
		received_data_len => open,
		received_data => received_data
	);

	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			do_send <= '0';
		elsif rising_edge(clk) then
			do_send <= '0';
			if received_valid = '1' and received_data = POLL_SEQUENCE then
				do_send <= '1';
			end if;
		end if;
	end process;


end architecture;