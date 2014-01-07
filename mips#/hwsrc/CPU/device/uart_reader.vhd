library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity uart_reader is
	port(
		rxd,uart_clk:in std_logic;
		enable:out std_logic;
		data:out std_logic_vector(7 downto 0)
	);
end;

architecture main of uart_reader is

type stat_type is (idle,datain,ending);
signal stat:stat_type:=idle;

signal c2:std_logic_vector(3 downto 0);

begin
	
	process(uart_clk)
	variable i:integer range 8 downto 0;
	begin
		if uart_clk'event and uart_clk='1' then
			case stat is
				when idle=>
					if rxd='0' then
						if c2="0111" then
							stat<=datain;
							c2<="0000";
							i:=0;
						else
							c2<=c2+1;
						end if;
					else
						c2<="0000";
					end if;
				when datain=>
					if c2="1111" then
						if i=8 then
							stat<=ending;
						else
							data(i)<=rxd;
							i:=i+1;
						end if;
					end if;
					c2<=c2+1;
				when ending=>
					stat<=idle;
			end case;
		end if;
	end process;
	
	enable<='1' when stat=ending else '0';
	
end;