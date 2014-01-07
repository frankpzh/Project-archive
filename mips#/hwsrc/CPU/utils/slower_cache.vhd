library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity slower_cache is
	port(
		clk_in:in std_logic;
		clk_out:buffer std_logic
	);
end;

architecture main of slower_cache is
signal ct:std_logic;
begin
	
	process(clk_in)
	begin
		if clk_in'event and clk_in='1' then
			ct<=not ct;
			if ct='0' then
				clk_out<=not clk_out;
			end if;
		end if;
	end process;
end;