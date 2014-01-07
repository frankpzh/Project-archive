library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity iou is
	port(
		clk,reset,isinst:in std_logic;
		
		NPC:in std_logic_vector(14 downto 0);
		en_NPC:in std_logic;
		
		PC:buffer std_logic_vector(14 downto 0):=(others=>'0')
	);
end;

architecture main of iou is

signal RPC:std_logic_vector(14 downto 0);

begin
	
	RPC<=PC+1 when en_NPC='0' else NPC;
	
	process(clk,reset)
	begin
		if reset='0' then
			PC<=(others=>'0');
		else
			if clk'event and clk='1' and isinst='1' then
				PC<=RPC;
			end if;
		end if;
	end process;
	
end;