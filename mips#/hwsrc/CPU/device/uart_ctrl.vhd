library ieee;
use ieee.std_logic_1164.all;

entity UART_ctrl is
	port (
		clk,UART_clk:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;

		--OUT
		rxd:in std_logic;
		txd:out std_logic		
	);
end;

architecture main of UART_ctrl is

	component fifo_uart IS
		port(
			rdclk,rdreq:in std_logic;
			wrclk,wrreq:in std_logic;
			data:in std_logic_vector(7 downto 0);
			q:out std_logic_vector(7 downto 0);
			empty:buffer std_logic;
			used:buffer std_logic_vector(7 downto 0)
		);
	END component;

	component uart_reader is
		port(
			rxd,uart_clk:in std_logic;
			enable:out std_logic;
			data:out std_logic_vector(7 downto 0)
		);
	end component;

	component uart_writer is
		port(
			txd:out std_logic;
			uart_ff,uart_clk:in std_logic;
			uart_data:in std_logic_vector(7 downto 0);
			uart_ff_out:buffer std_logic
		);
	end component;

signal read_ce,write_ce:std_logic;
signal uq:std_logic_vector(8 downto 0);

signal read_data:std_logic_vector(7 downto 0);
signal read_en,write_ff,write_ff_out,write_ff_reg:std_logic;

signal UART_ce,UART_busy:std_logic;
signal UART_q:std_logic_vector(8 downto 0);

begin
	
	--Bus Clock
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr="00000000100001000000010100001011" then
				if BUS_we='1' and write_ff_out=write_ff_reg then
					write_ff<=not write_ff_out;
				end if;
				write_ff_reg<=write_ff_out;
				UART_ce<='1';
			else
				UART_ce<='0';
			end if;
		end if;
	end process;
	
	--Output
	BUS_busy<=UART_busy when UART_ce='1' else 'Z';
	BUS_q<="0000000"&UART_q when UART_ce='1' else (others=>'Z');
	
	--Reader
	read_ce<=not BUS_we when UART_ce='1' else '0';
	
	reader0:uart_reader port map(rxd=>rxd,uart_clk=>UART_clk,
			enable=>read_en,data=>read_data);

	fifo0:fifo_uart port map(wrclk=>UART_clk,rdclk=>not clk,
			wrreq=>read_en,data=>read_data,rdreq=>read_ce,
			q=>UART_q(7 downto 0),empty=>UART_q(8));
	
	--Writer
	writer0:uart_writer port map(txd=>txd,uart_ff=>write_ff,
			uart_clk=>UART_clk,uart_data=>BUS_data(7 downto 0),
			uart_ff_out=>write_ff_out);

	UART_busy<=write_ff xor write_ff_out;
	
end;