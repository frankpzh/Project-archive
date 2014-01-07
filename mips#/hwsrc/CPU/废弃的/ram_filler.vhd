library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram_filler is
	port(
		clk,uart_clk,rxd,reset:in std_logic;
		
		out_addr:out std_logic_vector(27 downto 0);
		
		SRAM_addr:out std_logic_vector(17 downto 0);
		SRAM_data:out std_logic_vector(15 downto 0);
		SRAM_q:in std_logic_vector(15 downto 0);
		SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:out std_logic		
	);
end;

architecture main of ram_filler is

	component decoder is
		port(
			bits:in std_logic_vector(3 downto 0);
			seven:out std_logic_vector(6 downto 0)
		);
	end component;

	component uart_reader is
		port(
			rxd,uart_clk:in std_logic;
			enable:out std_logic;
			data:out std_logic_vector(7 downto 0)
		);
	end component;
	
signal significant:std_logic;
signal data:std_logic_vector(15 downto 0);
signal addr:std_logic_vector(17 downto 0):=(others=>'1');

signal enable_uart:std_logic;
signal data_uart:std_logic_vector(7 downto 0);

begin
	
	reader0:uart_reader port map(rxd=>rxd,uart_clk=>uart_clk,
						enable=>enable_uart,data=>data_uart);
	
	SRAM_addr<=addr;
	SRAM_data<=data;
	SRAM_n_we<='0';
	SRAM_n_oe<='1';
	SRAM_n_ub<=significant;
	SRAM_n_lb<=not significant;
	SRAM_n_ce<='0';
	
	process(reset,uart_clk)
	begin
		if reset='0' then
			addr<=(others=>'1');
			significant<='0';
		elsif uart_clk'event and uart_clk='0' then
			if enable_uart='1' then
				if significant='0' then
					addr<=addr+1;
					data<="00000000"&data_uart;
					significant<='1';
				else
					data<=data_uart&"00000000";
					significant<='0';
				end if;
			end if;
		end if;
	end process;
	
	u5:decoder port map(bits=>addr(3 downto 0),seven=>out_addr(6 downto 0));
	u6:decoder port map(bits=>addr(7 downto 4),seven=>out_addr(13 downto 7));
	u7:decoder port map(bits=>addr(11 downto 8),seven=>out_addr(20 downto 14));
	u8:decoder port map(bits=>addr(15 downto 12),seven=>out_addr(27 downto 21));

end;