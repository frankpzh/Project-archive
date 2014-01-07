library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity slower_wm8731 is
	port(
		clk_in:in std_logic;
		clk_out:buffer std_logic
	);
end;

architecture main of slower_wm8731 is

signal clr,clr1,clr2:std_logic;
signal output:std_logic_vector(2 downto 0);

begin
	
	clk_out<='0' when output<"010" else '1';
	
	process(clk_in)
	begin
		if clk_in'event and clk_in='0' then
			if output="100" then 
				clr1<='1';
			else
				clr1<='0';
			end if;
		end if;
	end process;
	
	process(clk_in)
	begin
		if clk_in'event and clk_in='1' then
			clr2<=not clr1;
		end if;
	end process;
	
	clr<=clr1 and clr2;

	process(clk_in,clr)
	begin
		if clr='1' then
			output<="000";
		elsif clk_in'event and clk_in='1' then
			output<=output+1;
		end if;
	end process;

end;