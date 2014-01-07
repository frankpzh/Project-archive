library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity offsetter is
	port(
		PC:in std_logic_vector(31 downto 0);
		offset:in std_logic_vector(10 downto 0);
		NPC:out std_logic_vector(31 downto 0)
	);
end;

architecture main of offsetter is
begin

	NPC<=PC+offset;
	
end;
