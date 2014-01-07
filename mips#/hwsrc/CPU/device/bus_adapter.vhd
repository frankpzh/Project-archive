library ieee;
use ieee.std_logic_1164.all;

entity bus_adapter is
	port (
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		DEV_we:out std_logic;
		DEV_addr:out std_logic_vector(31 downto 0);
		DEV_data:out std_logic_vector(15 downto 0);
		DEV_cs:in std_logic;
		DEV_q:in std_logic_vector(15 downto 0);
		DEV_busy:in std_logic
	);
end;

architecture main of bus_adapter is
begin
	DEV_we<=BUS_we;
	DEV_addr<=BUS_addr;
	DEV_data<=BUS_data;
	BUS_q<=DEV_q when DEV_cs='1' else (others=>'Z');
	BUS_busy<=DEV_busy when DEV_cs='1' else 'Z';
end;