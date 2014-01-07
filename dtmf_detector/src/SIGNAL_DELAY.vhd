library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SIGNAL_DELAY is
	port (
		CLK,reset:in std_logic;
		SIGNAL_IN:in std_logic_vector(15 downto 0);
		SIGNAL_OUT,SIGNAL_LATE:buffer std_logic_vector(7 downto 0)
	);
end;

architecture main of SIGNAL_DELAY is

component queue IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		wraddress		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		wren		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;

signal pt:std_logic_vector(12 downto 0);
signal SIG:std_logic_vector(7 downto 0);

begin
	
	SIG<=(others=>'0') when reset='1' else
		SIGNAL_IN(11 downto 4) when SIGNAL_IN(15 downto 11)="00000" else
		SIGNAL_IN(11 downto 4) when SIGNAL_IN(15 downto 11)="11111" else
		"01111111" when SIGNAL_IN(15)='0' else
		"10000000";
	
	u0:queue port map(clock=>not CLK,data=>SIG,rdaddress=>pt,
					wraddress=>pt,wren=>'1',q=>SIGNAL_LATE);
	
	process(clk)
	begin
		if clk'event and clk='1' then
			pt<=pt+1;
		end if;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='0' then
			SIGNAL_OUT<=SIG;
		end if;
	end process;
	
end;