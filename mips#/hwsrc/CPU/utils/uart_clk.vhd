library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity uart_clk is
	port(
		pll_clk:in std_logic;
		uart_clk:buffer std_logic
	);
end;

architecture main of uart_clk is
signal c1:std_logic_vector(5 downto 0):="000000";
begin

	process(pll_clk)
	begin
		if pll_clk'event and pll_clk='1' then
			if c1="110101" then
				uart_clk<=not uart_clk;
				c1<="000000";
			else
				c1<=c1+1;
			end if;
		end if;
	end process;
	
end;