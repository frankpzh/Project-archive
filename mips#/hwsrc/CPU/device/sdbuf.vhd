library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sdbuf is
	port(
		clk:in std_logic;
		
		--BUS
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--SD Card
		BUF_clk,BUF_we:in std_logic;
		BUF_addr:in std_logic_vector(8 downto 0);
		BUF_data:in std_logic_vector(7 downto 0)
	);
end;

architecture main of sdbuf is

	component ram_sd IS
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdclock		: IN STD_LOGIC ;
			wraddress		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			wrclock		: IN STD_LOGIC ;
			wren		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;

signal cs:std_logic;
signal q:std_logic_vector(15 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr(31 downto 8)="000000001000010000000100" then
				cs<='1';
			else
				cs<='0';
			end if;
		end if;
	end process;
	
	BUS_busy<='0' when cs='1' else 'Z';
	BUS_q<=q when cs='1' else (others=>'Z');
	
	u0:ram_sd port map(rdaddress=>BUS_addr(7 downto 0),rdclock=>clk,
						q=>q,wren=>BUF_we,wraddress=>BUF_addr,
						data=>BUF_data,wrclock=>BUF_clk);
	
end;