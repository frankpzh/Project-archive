library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity accumulator is
	generic(
		HI:std_logic_vector(1 downto 0):="00";
		STEP:std_logic_vector(13 downto 0):="00000000000001"
	);
	port(
		CLK,reset:in std_logic;
		DAC_IN,DAC_LATE:in std_logic_vector(7 downto 0);
		SIGNAL_DETECTED:out std_logic
	);
end;

architecture main of accumulator is

component DDS IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;

signal PHASE1,PHASE2:std_logic_vector(15 downto 0);
signal SINE_IN1,SINE_LATE1:std_logic_vector(7 downto 0);
signal SINE_IN2,SINE_LATE2:std_logic_vector(7 downto 0);

signal REG1,REG2:std_logic_vector(28 downto 0):=(others=>'0');
signal A:std_logic_vector(57 downto 0);
--signal PART2:std_logic_vector(62 downto 0);

--constant SQRT2:std_logic_vector(10 downto 0):="10110101000";

begin

	process(clk,reset)
	begin
		if reset='1' then
			REG1<=(others=>'0');
			REG2<=(others=>'0');
			SIGNAL_DETECTED<='0';
		elsif clk'event and clk='1' then
			REG1<=REG1+SINE_IN1*DAC_IN-SINE_LATE1*DAC_LATE;
			REG2<=REG2+SINE_IN2*DAC_IN-SINE_LATE2*DAC_LATE;
			PHASE1<=PHASE1+STEP;
			if HI(1)='1' then
				if A(57 downto 43)="0" then
					SIGNAL_DETECTED<='0';
				else
					SIGNAL_DETECTED<='1';
				end if;
			else
				if A(57 downto 40)="0" then
					SIGNAL_DETECTED<='0';
				else
					SIGNAL_DETECTED<='1';
				end if;
			end if;
		end if;
	end process;
	
	--PART2<=REG1*REG2*SQRT2;
	A<=(REG1*REG1)+(REG2*REG2);
	PHASE2<=PHASE1-(STEP(2 downto 0)&"0000000000000");
	
	u0:DDS port map(clock=>not clk,address=>PHASE1(15 downto 7),q=>SINE_IN1);
	u1:DDS port map(clock=>not clk,address=>(PHASE1(15 downto 14)+"01")&PHASE1(13 downto 7),q=>SINE_IN2);
	u2:DDS port map(clock=>not clk,address=>PHASE2(15 downto 7),q=>SINE_LATE1);
	u3:DDS port map(clock=>not clk,address=>(PHASE2(15 downto 14)+"01")&PHASE2(13 downto 7),q=>SINE_LATE2);
	
end;