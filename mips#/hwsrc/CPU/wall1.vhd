library ieee;
use ieee.std_logic_1164.all;

entity wall1 is
	port(
		clk,door1:in std_logic;
		CC_en:in std_logic;
		CC_inst:in std_logic_vector(15 downto 0);
		CU_en:out std_logic:='0';
		CU_inst:out std_logic_vector(15 downto 0)
	);
end;

architecture main of wall1 is
begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if door1='1' then
				CU_en<=CC_en;
				CU_inst<=CC_inst;
			end if;
		end if;
	end process;
	
end;