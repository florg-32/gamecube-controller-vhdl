library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;
use work.sync_pkg.all;

--! This module handles the sending and receiving of a single-wire pulsewidth-encoded signal.
--! If the data signal is pulled low, the module automatically goes into receive mode until there are no more bits sent.
entity pulsewidth_encoder is
	generic (
		SEND_DATA_MAXLEN : natural := 25; --! Maximum number of bits to send once
		RECV_DATA_MAXLEN : natural := 65; --! Maximum number of bits to receive once
		ZERO_LOWCYCLES : natural; --! Number of cycles the signal is low for a '0'
		ONE_LOWCYCLES : natural; --! Number of cycles the signal is low for a '1'
		WAIT_CYCLES : natural; --! Number of cycles to wait after a falling edge before sampling

		SYNC_STAGES : natural := 2 --! Synchronizer stages for the data signal
	);
	port (
		clk : in std_logic;
		res_n : in std_logic;

		data : inout std_logic;

		do_send : in std_logic; --! Starts the transmission of send_data, should be high for one cycle
		send_data_len : in natural range 0 to SEND_DATA_MAXLEN; --! Number of bits to send, must be valid with do_send
		send_data : in std_logic_vector(SEND_DATA_MAXLEN - 1 downto 0); --! Data to send, must be valid with do_send

		received_valid : out std_logic; --! Indicates received_data is valid, this happens after WAIT_CYCLES + ZERO_CYCLES without a falling edge on data
		received_data_len : out natural range 0 to max(RECV_DATA_MAXLEN, SEND_DATA_MAXLEN)+1; --! The number of bits received, valid after received_valid. RECV_DATA_MAXLEN+1 indicates an overflow
		received_data : out std_logic_vector(RECV_DATA_MAXLEN - 1 downto 0) --! The received data, last bit received is the LSB
	);
end entity;

architecture rtl of pulsewidth_encoder is

	type pwe_state is (IDLE, SEND, SEND_LOW, SEND_HIGH, WAIT_SAMPLE, SAMPLE_DATA, WAIT_FOR_FALLING);
	signal state : pwe_state := IDLE;

	signal send_data_len_reg : natural range 0 to SEND_DATA_MAXLEN;
	signal send_data_reg : std_logic_vector(SEND_DATA_MAXLEN - 1 downto 0);
	signal recveived_reg : std_logic_vector(RECV_DATA_MAXLEN - 1 downto 0);
	signal received_valid_reg : std_logic;

	signal data_cnt : natural range 0 to max(RECV_DATA_MAXLEN, SEND_DATA_MAXLEN)+1;
	signal clk_cnt : natural range 0 to ZERO_LOWCYCLES+1; -- +1 because of simulation

	signal data_synced, data_synced_old, data_in_sig : std_logic;

begin
	data_in_sig <= '0' when data = '0' else '1';
	data_sync_inst : sync
	generic map(
		SYNC_STAGES => SYNC_STAGES,
		RESET_VALUE => '1'
	)
	port map(
		clk => clk,
		res_n => '1',
		data_in => data_in_sig,
		data_out => data_synced
	);

	sync : process (res_n, clk)
	begin
		if res_n = '0' then
			state <= IDLE;
			send_data_reg <= (others => '0');
			send_data_len_reg <= 0;
			recveived_reg <= (others => '0');
			received_valid_reg <= '0';
			data_cnt <= 0;
			clk_cnt <= 0;
		elsif rising_edge(clk) then
			data_synced_old <= data_synced;

			case state is
				when IDLE =>
					received_valid_reg <= '0';
					if data_synced = '0' and data_synced_old = '1' then
						state <= WAIT_SAMPLE;
					elsif do_send = '1' then
						state <= SEND;
						send_data_len_reg <= send_data_len;
						send_data_reg <= send_data;
					end if;

				when SEND =>
					if data_cnt < send_data_len_reg then
						state <= SEND_LOW;
						data_cnt <= data_cnt + 1;
					else
						state <= IDLE;
						data_cnt <= 0;
					end if;

				when SEND_LOW =>
					clk_cnt <= clk_cnt + 1;
					if (send_data_reg(send_data_reg'left) = '0' and clk_cnt = ZERO_LOWCYCLES) or
						(send_data_reg(send_data_reg'left) = '1' and clk_cnt = ONE_LOWCYCLES) then
						clk_cnt <= 0;
						state <= SEND_HIGH;
					end if;

				when SEND_HIGH =>
					clk_cnt <= clk_cnt + 1;
					if (send_data_reg(send_data_reg'left) = '0' and clk_cnt = ONE_LOWCYCLES) or
						(send_data_reg(send_data_reg'left) = '1' and clk_cnt = ZERO_LOWCYCLES) then
						clk_cnt <= 0;
						send_data_reg <= send_data_reg(send_data_reg'left - 1 downto 0) & '0';
						state <= SEND;
					end if;

				when WAIT_SAMPLE =>
					clk_cnt <= clk_cnt + 1;
					if clk_cnt = WAIT_CYCLES then
						clk_cnt <= 0;
						state <= SAMPLE_DATA;
					end if;

				when SAMPLE_DATA =>
					recveived_reg <= recveived_reg(recveived_reg'left-1 downto 0) & data_synced;
					if data_cnt <= RECV_DATA_MAXLEN then
						data_cnt <= data_cnt + 1; -- saturation signals overflow
					end if;
					state <= WAIT_FOR_FALLING;

				when WAIT_FOR_FALLING =>
					clk_cnt <= clk_cnt + 1;
					if data_synced = '0' and data_synced_old = '1' then
						state <= WAIT_SAMPLE;
						clk_cnt <= 0;
					elsif clk_cnt = ZERO_LOWCYCLES then
						state <= IDLE;
						received_valid_reg <= '1';
						data_cnt <= 0;
						clk_cnt <= 0;
					end if;
			end case;
		end if;
	end process;

	received_data <= recveived_reg;
	received_valid <= received_valid_reg;
	received_data_len <= data_cnt;

	data <= '0' when state = SEND_LOW else 'Z';

end architecture;