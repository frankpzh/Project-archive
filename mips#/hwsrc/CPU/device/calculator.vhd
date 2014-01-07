library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity calculator is
	port(
		clk:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_cs:out std_logic;
		BUS_q:out std_logic_vector(15 downto 0);
		BUS_busy:out std_logic
	);
end;

architecture main of calculator is

	component mult16s IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			dataa		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END component;

	component mult16u IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			dataa		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END component;

	component mult32u IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END component;

	component divide16s IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			denom		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			remain		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;

	component divide16u IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			denom		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			remain		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;

type stat_type is (idle, working);
signal stat:stat_type:=idle;
signal busy1, busy2, busy_last:std_logic:='0';

signal op:std_logic_vector(2 downto 0):=(others=>'0');
signal A, B, C:std_logic_vector(31 downto 0):=(others=>'0');
signal D:std_logic_vector(15 downto 0):=(others=>'0');

signal mult0result, mult1result, mult2result:std_logic_vector(31 downto 0);
signal div0quot, div1quot:std_logic_vector(31 downto 0);
signal div0remain, div1remain:std_logic_vector(15 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr(31 downto 3)="00000000100001000000010100100" then
				BUS_cs<='1';
				if BUS_we='1' and busy_last='0' then
					case BUS_addr(2 downto 0) is
					when "000"=>
						A(15 downto 0)<=BUS_data;
					when "001"=>
						A(31 downto 16)<=BUS_data;
					when "010"=>
						B(15 downto 0)<=BUS_data;
					when "011"=>
						B(31 downto 16)<=BUS_data;
					when "111"=>
						op<=BUS_data(2 downto 0);
						busy1<=not busy2;
					when others=>
					end case;
				end if;
			else
				BUS_cs<='0';
			end if;
		end if;
	end process;
	
	BUS_busy<=busy1 xor busy2;
	
	BUS_q<=A(15 downto 0)	when BUS_addr(2 downto 0)="000" else
		A(31 downto 16)		when BUS_addr(2 downto 0)="001" else
		B(15 downto 0)		when BUS_addr(2 downto 0)="010" else
		B(31 downto 16)		when BUS_addr(2 downto 0)="011" else
		C(15 downto 0)		when BUS_addr(2 downto 0)="100" else
		C(31 downto 16)		when BUS_addr(2 downto 0)="101" else
		D					when BUS_addr(2 downto 0)="110" else
		(others=>'0');
	
	mult0:mult16s port map(clock=>clk, dataa=>A(15 downto 0),
			datab=>B(15 downto 0), result=>mult0result);
	mult1:mult16u port map(clock=>clk, dataa=>A(15 downto 0),
			datab=>B(15 downto 0), result=>mult1result);
	mult2:mult32u port map(clock=>clk, dataa=>A, datab=>B,
			result=>mult2result);
	div0:divide16s port map(clock=>clk, denom=>B(15 downto 0),
			numer=>A, quotient=>div0quot, remain=>div0remain);
	div1:divide16u port map(clock=>clk, denom=>B(15 downto 0),
			numer=>A, quotient=>div1quot, remain=>div1remain);
	
	process(clk)
	variable i:integer range 15 downto 0;
	begin
		if clk'event and clk='0' then
			busy_last<=busy1 xor busy2;
			case stat is
			when idle=>
				if not(busy1=busy2) then
					case op is
					when "000"=>
						i:=4;
					when "001"=>
						i:=4;
					when "010"=>
						i:=4;
					when "011"=>
						i:=9;
					when "100"=>
						i:=9;
					when others=>
						i:=1;
					end case;
					stat<=working;
				end if;
			when working=>
				i:=i-1;
				if i=0 then
					case op is
					when "000"=>
						C<=mult0result;
					when "001"=>
						C<=mult1result;
					when "010"=>
						C<=mult2result;
					when "011"=>
						C<=div0quot;
						D<=div0remain;
					when "100"=>
						C<=div1quot;
						D<=div1remain;
					when others=>
					end case;
					busy2<=busy1;
					stat<=idle;
				end if;
			end case;
		end if;
	end process;
	
end;
