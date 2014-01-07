library ieee;
use ieee.std_logic_1164.all;

entity keyboard_ctrl is
	port(
		reset,clk:in std_logic;
		
		KCLK,KDAT:in std_logic;
		up,down,left,enter,pgup,pgdown:buffer std_logic
	);
end;

architecture main of keyboard_ctrl is

signal nclk:std_logic;

signal e0,f0:std_logic;
signal data:std_logic_vector(7 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			nclk<=KCLK;
		end if;
	end process;
	
	process(nclk,reset)
	variable i:integer range 0 to 10:=0;
	begin
		if reset='1' then
			i:=0;
			e0<='0';
			f0<='0';
			up<='0';
			down<='0';
			left<='0';
			enter<='0';
			pgup<='0';
			pgdown<='0';
		elsif nclk'event and nclk='0' then
			if i>0 and i<=8 then
				data(i-1)<=KDAT;
			elsif i=10 then
				if data="11100000" then
					e0<='1';
				elsif data="11110000" then
					f0<='1';
				else
					if (data&e0&f0)="0111010110" then
						up<=not up;
					elsif (data&e0&f0)="0111001010" then
						down<=not down;
					elsif (data&e0&f0)="0101101000" then
						enter<=not enter;
					elsif (data&e0&f0)="0111110110" then
						pgup<=not pgup;
					elsif (data&e0&f0)="0111101010" then
						pgdown<=not pgdown;
					elsif (data&e0&f0)="0110101110" then
						left<=not left;
					end if;
					e0<='0';
					f0<='0';
				end if;
			end if;
			if i=10 then
				i:=0;
			else
				i:=i+1;
			end if;
		end if;
	end process;
	
end;