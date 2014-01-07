library ieee;
use ieee.std_logic_1164.all;

entity textbuf is
	port(
		clk,clk_lcd:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--LCD
		LCD_addr:in std_logic_vector(9 downto 0);
		LCD_q:out std_logic_vector(15 downto 0)
	);
end;

architecture main of textbuf is

	component ram_TextBuf IS
		PORT
		(
			address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			address_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			clock_a		: IN STD_LOGIC ;
			clock_b		: IN STD_LOGIC ;
			data_a		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren_a		: IN STD_LOGIC  := '1';
			wren_b		: IN STD_LOGIC  := '1';
			q_a		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			q_b		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;

signal BUS_cs,isTxt:std_logic;
signal ram_q:std_logic_vector(15 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			BUS_cs<=isTxt;
		end if;
	end process;
	isTxt<='1' when BUS_addr(31 downto 10)="0000000010000100000000" else '0';
	BUS_q<=ram_q when BUS_cs='1' else (others=>'Z');
	BUS_busy<='0' when BUS_cs='1' else 'Z';
	
	uram:ram_TextBuf port map(clock_a=>clk,clock_b=>clk_lcd,
		address_a=>BUS_addr(9 downto 0),data_a=>BUS_data,
		wren_a=>isTxt and BUS_we,q_a=>ram_q,address_b=>LCD_addr,
		wren_b=>'0',q_b=>LCD_q,data_b=>(others=>'0'));
	
end;