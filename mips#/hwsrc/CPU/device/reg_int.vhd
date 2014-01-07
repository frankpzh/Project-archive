library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_int is
	port(
		clk:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic
	);
end;

architecture main of reg_int is

signal cs:std_logic;
signal q:std_logic_vector(15 downto 0);

signal reg:std_logic_vector(129 downto 0):=(others=>'0');

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr(31 downto 4)="0000000010000100000001010001" then
				cs<='1';
				if BUS_we='1' then
					case BUS_addr(3 downto 0) is
					when "0000"=>
						reg(15 downto 0)<=BUS_data;
					when "0001"=>
						reg(31 downto 16)<=BUS_data;
					when "0010"=>
						reg(47 downto 32)<=BUS_data;
					when "0011"=>
						reg(63 downto 48)<=BUS_data;
					when "0100"=>
						reg(79 downto 64)<=BUS_data;
					when "0101"=>
						reg(95 downto 80)<=BUS_data;
					when "0110"=>
						reg(111 downto 96)<=BUS_data;
					when "0111"=>
						reg(127 downto 112)<=BUS_data;
					when "1000"=>
						reg(129 downto 128)<=BUS_data(1 downto 0);
					when others=>
					end case;
				end if;
			else
				cs<='0';
			end if;
		end if;
	end process;
	
	BUS_busy<='0' when cs='1' else 'Z';
	BUS_q<=q when cs='1' else (others=>'Z');
	
	with BUS_addr(3 downto 0) select
	q<=	REG(15 downto 0) when "0000",
		REG(31 downto 16) when "0001",
		REG(47 downto 32) when "0010",
		REG(63 downto 48) when "0011",
		REG(79 downto 64) when "0100",
		REG(95 downto 80) when "0101",
		REG(111 downto 96) when "0110",
		REG(127 downto 112) when "0111",
		"00000000000000"&REG(129 downto 128) when "1000",
		(others=>'0') when others;
	
end;