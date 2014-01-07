library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity decoder is
	port(
		bits:in std_logic_vector(3 downto 0);
		seven:out std_logic_vector(6 downto 0)
	);
end;

architecture main of decoder is
begin

	seven(0)<='0' when bits=0 or bits=2 or bits=3 or bits=5 or bits=6 or 
						bits=7 or bits=8 or bits=9 or bits=10 or 
						bits=12 or bits=14 or bits=15 else '1';
	seven(1)<='0' when bits=0 or bits=1 or bits=2 or bits=3 or bits=4 or 
						bits=7 or bits=8 or bits=9 or bits=10 or 
						bits=13 else '1';
	seven(2)<='0' when bits=0 or bits=1 or bits=3 or bits=4 or bits=5 or 
						bits=6 or bits=7 or bits=8 or bits=9 or 
						bits=10 or bits=11 or bits=13 else '1';
	seven(3)<='0' when bits=0 or bits=2 or bits=3 or bits=5 or bits=6 or 
						bits=8 or bits=9 or bits=11 or bits=12 or 
						bits=13 or bits=14 else '1';
	seven(4)<='0' when bits=0 or bits=2 or bits=6 or bits=8 or bits=10 or 
						bits=11 or bits=12 or bits=13 or bits=14 or bits=15 else '1';
	seven(5)<='0' when bits=0 or bits=4 or bits=5 or bits=6 or bits=8 or 
						bits=9 or bits=10 or bits=11 or bits=12 or bits=14 or 
						bits=15 else '1';
	seven(6)<='0' when bits=2 or bits=3 or bits=4 or bits=5 or 
						bits=6 or bits=8 or bits=9 or bits=10 or 
						bits=11 or bits=13 or bits=14 or bits=15 else '1';

end;