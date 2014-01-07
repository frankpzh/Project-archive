library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity uart_writer is
	port(
		txd:out std_logic;
		uart_ff,uart_clk:in std_logic;
		uart_data:in std_logic_vector(7 downto 0);
		uart_ff_out:buffer std_logic
	);
end;

architecture main of uart_writer is

type stat_type is (idle,data,ending);
signal stat:stat_type:=idle;

signal uart_clk_16:std_logic;
signal counter:std_logic_vector(2 downto 0);

begin

	process(uart_clk)
	begin
		if uart_clk'event and uart_clk='1' then
			counter<=counter+1;
			if counter="000" then
				uart_clk_16<=not uart_clk_16;
			end if;
		end if;
	end process;

	process(uart_clk_16)
	variable i:integer range 0 to 10;
	begin
		if uart_clk_16'event and uart_clk_16='1' then
			case stat is
				when idle=>
					if (not uart_ff)=uart_ff_out then
						txd<='0';
						stat<=data;
						i:=0;
					else
						txd<='1';
					end if;
				when data=>
					txd<=uart_data(i);
					if i=7 then
						stat<=ending;
					end if;
					i:=i+1;
				when ending=>
					uart_ff_out<=uart_ff;
					txd<='1';
					stat<=idle;
			end case;
		end if;
	end process;
	
end;