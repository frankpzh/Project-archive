library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity slower_lcd is
	port(
		clk_in:in std_logic;
		clk_out:buffer std_logic
	);
end;

architecture main of slower_lcd is
signal counter:std_logic_vector(1 downto 0);
begin
	
	process(clk_in)
	begin
		if clk_in'event and clk_in='1' then
			counter<=counter+1;
			if counter="0" then
				clk_out<=not clk_out;
			end if;
		end if;
	end process;
end;