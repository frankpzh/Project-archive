library ieee;
use ieee.std_logic_1164.all;

entity boot is
	port(
		clk:in std_logic;
		
		--BUS
		addr:in std_logic_vector(31 downto 0);
		q:inout std_logic_vector(15 downto 0);
		busy:inout std_logic
	);
end;

architecture main of boot is

	component rom_boot IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;

signal cs:std_logic;
signal rom_q:std_logic_vector(15 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if addr(31 downto 22)="0000000000" then
				cs<='1';
			else
				cs<='0';
			end if;
		end if;
	end process;
	q<=rom_q when cs='1' else (others=>'Z');
	busy<='0' when cs='1' else 'Z';
	
	urom:rom_boot port map(address=>addr(12 downto 0),q=>rom_q,clock=>clk);
	
end;