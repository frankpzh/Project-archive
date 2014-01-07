library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity timer is
	port(
		clk:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--Interrupt(Rising Edge)
		INT_clock:buffer std_logic;
		
		--timer
		clk50:in std_logic
	);
end;

architecture main of timer is

signal cs:std_logic;
signal q:std_logic_vector(15 downto 0);

signal setter:std_logic_vector(15 downto 0);
signal set_pos,set_ena,set_enb:std_logic:='0';
signal delay:std_logic_vector(15 downto 0):=(others=>'0');
signal counter:std_logic_vector(30 downto 0):=(others=>'0');

signal setInt,clrInt:std_logic;

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr(31 downto 2)="000000001000010000000101000010" then
				cs<='1';
				if BUS_we='1' then
					clrInt<=setInt;
				end if;
			else
				cs<='0';
			end if;
		end if;
	end process;
	
	BUS_busy<='0' when cs='1' else 'Z';
	BUS_q<=q when cs='1' else (others=>'Z');
	INT_clock<=setInt xor clrInt;
	
	q<=INT_clock&counter(30 downto 16) when BUS_addr(1 downto 0)="01" else
		counter(15 downto 0) when BUS_addr(1 downto 0)="00" else
		(others=>'0');
	
	process(clk50)
	begin
		if clk50'event and clk50='1' then
			if delay="1100001101010000" then
				delay<=(others=>'0');
				counter<=counter+1;
				if counter(2 downto 0)="000" then
					setInt<=not clrInt;
				end if;
			else
				delay<=delay+1;
			end if;
		end if;
	end process;
	
end;