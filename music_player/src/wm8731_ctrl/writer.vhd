library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity writer is
	port(
		datin:in std_logic_vector(15 downto 0);
		clk,we:in std_logic;
		done,noerr:out std_logic;
		
		SCLK:buffer std_logic:='1';
		SDIN:inout std_logic:='1'
	);
end;

architecture main of writer is

type stat_type is (idle,
					init,
					start,
					send_addr_a,
					send_addr_b,
					wait_step,
					wait_resp,
					send_data_a,
					send_data_b,
					wait_step1,
					wait_resp1,
					wait_done,
					wait_resp2,
					end_it);
signal stat:stat_type:=idle;

constant addr:std_logic_vector(7 downto 0):="00110100";

begin

	process(clk)
	variable i:integer range 0 to 15;
	begin
		if clk'event and clk='0' then
			case stat is
				when init=>
					SDIN<='1';
					stat<=start;
					
				when start=>
					SDIN<='0';
					i:=7;
					stat<=send_addr_a;

				when send_addr_a=>
					SDIN<=addr(i);
					stat<=send_addr_b;

				when send_addr_b=>
					i:=i-1;
					if i=15 then
						stat<=wait_step;
					else
						stat<=send_addr_a;
					end if;
				
				when wait_step=>
					SDIN<='0';
					stat<=wait_resp;
				
				when wait_resp=>
					if SDIN='0' then
						i:=15;
						stat<=send_data_a;
					else
						noerr<='0';
						stat<=end_it;
					end if;
					
				when send_data_a=>
					SDIN<=datin(i);
					stat<=send_data_b;

				when send_data_b=>
					i:=i-1;
					if i=15 then
						stat<=wait_done;
					elsif i=7 then
						stat<=wait_step1;
					else
						stat<=send_data_a;
					end if;
				
				when wait_step1=>
					SDIN<='0';
					stat<=wait_resp1;
				
				when wait_resp1=>
					if SDIN='0' then
						stat<=send_data_a;
					else
						noerr<='0';
						stat<=end_it;
					end if;					
				
				when wait_done=>
					SDIN<='0';
					stat<=wait_resp2;
				
				when wait_resp2=>
					if SDIN='0' then
						noerr<='1';
					else
						noerr<='0';
					end if;					
					stat<=end_it;
				
				when end_it=>
					SDIN<='1';
					done<='1';
					stat<=idle;
				
				when idle=>
					SDIN<='1';
					if we='1' then
						noerr<='0';
						done<='0';
						stat<=init;
					end if;
				
			end case;
		end if;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			case stat is
				when send_addr_a=>
					SCLK<='0';
				
				when wait_step=>
					SCLK<='0';
				
				when send_data_a=>
					SCLK<='0';
				
				when wait_step1=>
					SCLK<='0';
				
				when wait_done=>
					SCLK<='0';
				
				when others=>
					SCLK<='1';
			end case;
		end if;
	end process;
end;