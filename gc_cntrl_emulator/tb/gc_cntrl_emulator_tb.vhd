library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.math_pkg.all;
use work.gc_cntrl_pkg.all;
use work.gc_cntrl_emulator_pkg.all;

entity gc_cntrl_emulator_tb is
end entity;

architecture tb of gc_cntrl_emulator_tb is
	signal gc_state, gc_state_recv : gc_cntrl_state_t := GC_BUTTONS_RESET_VALUE;

	signal clk, res_n : std_logic := '0';
	signal data : std_logic := 'Z';
	signal received_data : std_logic_vector(64 downto 0);
	signal gc_res : std_logic := '0';

	constant POLL_SEQUENCE : std_logic_vector(0 to 24) := x"400302" & "1";
begin

	uut : gc_cntrl_emulator
	port map(
		clk => clk,
		res_n => res_n,
		data => data,
		button_state => gc_state,
		rumble => open
	);

	gc_cntrl_inst : entity work.gc_cntrl
	port map(
		clk => clk,
		res_n => gc_res,
		data => data,
		cntrl_state => gc_state_recv
	);

	stimulus : process
		procedure send_bits (bits : std_logic_vector) is
		begin
			for b in bits'range loop
				if bits(b) = '0' then
					data <= '0';
					wait for 3 us;
					data <= 'Z';
					wait for 1 us;
				else
					data <= '0';
					wait for 1 us;
					data <= 'Z';
					wait for 3 us;
				end if;
			end loop;
		end procedure;
		procedure read_bits (n_bits : natural) is
		begin
			for i in n_bits - 1 downto 0 loop
				wait until data = '0';
				wait for 2 us;
				received_data(i) <= '0' when data = '0' else '1';
			end loop;
		end procedure;
	begin
		gc_state.btn_a <= '1';
		gc_state.btn_x <= '1';
		gc_state.trigger_r <= x"54";
		res_n <= '1';
		wait for 20 ns;
		report "Sending poll sequence...";
		send_bits(POLL_SEQUENCE);

		report "Reading button states...";
		read_bits(65);
		wait until rising_edge(clk);
		assert to_gc_cntrl_state(received_data(64 downto 1)) = gc_state report "Button mismatch " & to_hstring(received_data) & "/=" & to_hstring(to_slv(gc_state));

		report "Testing with gc_cntrl...";
		gc_res <= '1';
		wait until gc_state_recv'event;
		assert gc_state_recv = gc_state report "Button mismatch with gc_cntrl";

		report "Simulation finished";
		finish;
	end process;

	clk_gen : process
	begin
		while true loop
			clk <= not clk after 10 ns;
			wait for 10 ns;
		end loop;
	end process;

end architecture;