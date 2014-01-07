library ieee;
use ieee.std_logic_1164.all;

-- Interrupt Controller
entity ic is
	port(
		clk,reset_n:in std_logic;
		
		timer,kbd,wm8731,soft:in std_logic;
		
		int:out std_logic;
		int_commit:in std_logic;
		
		int_code:out std_logic_vector(3 downto 0)
	);
end;

architecture main of ic is
type stat_type is (idle, wait_commit);
signal stat:stat_type:=idle;
signal int_open:std_logic:='0';
begin

	process(clk,reset_n)
	begin
		if reset_n='0' then
			stat<=idle;
			int<='0';
			int_open<='0';
			int_code<="0000";
		elsif clk'event and clk='0' then
			case stat is
			when idle=>
				if soft='1' then
					int<='1';
					int_code<="0001";
					stat<=wait_commit;
				elsif (timer and int_open)='1' then
					int<='1';
					int_code<="0010";
					stat<=wait_commit;
				elsif (kbd and int_open)='1' then
					int<='1';
					int_code<="0100";
					stat<=wait_commit;
				elsif (wm8731 and int_open)='1' then
					int<='1';
					int_code<="1000";
					stat<=wait_commit;
				end if;
			when wait_commit=>
				if int_commit='1' then
					int<='0';
					int_open<=not int_open;
					stat<=idle;
				end if;
			end case;
		end if;
	end process;

end;