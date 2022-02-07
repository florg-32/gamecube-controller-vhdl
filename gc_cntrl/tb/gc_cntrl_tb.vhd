library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.gc_cntrl_pkg.all;

entity gc_cntrl_tb is
end entity;

architecture tb of gc_cntrl_tb is
	signal gc_state : gc_cntrl_state_t := GC_BUTTONS_RESET_VALUE;

	signal clk, res_n : std_logic := '0';

	signal data : std_logic := 'Z';
	signal do_send, received_valid : std_logic;
	signal received_data : std_logic_vector(63 downto 0);

	signal received_buttons : gc_cntrl_state_t;

begin

	uut : gc_cntrl
	port map (
		clk => clk,
		res_n => res_n,
		data => data,
		cntrl_state => received_buttons
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
			for i in n_bits-1 downto 0 loop
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

		report "Testing conversion functions...";
		assert to_slv(gc_state) = x"0580000000000054" report "to_slv() failed" severity failure;
		assert gc_state = to_gc_cntrl_state(x"0580000000000054") report "to_gc_cntrl_state() failed" severity failure;
		assert gc_state = to_gc_cntrl_state(to_slv(gc_state)) report "Conversion functions failed" severity failure;
		
		report "Receiving poll sequence...";
		read_bits(25);
		wait until rising_edge(clk);
		assert received_data(24 downto 0) = (x"400302" & "1") report "poll sequence wrong ... " & to_hstring(received_data(24 downto 0)) severity failure;
		
		wait for 8 us;
		report "Sending button states...";
		send_bits(to_slv(gc_state) & "1");
		wait for 3 us;
		assert received_buttons = gc_state report "Button mismatch " & to_hstring(to_slv(received_buttons)) & "/=" & to_hstring(to_slv(gc_state));

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