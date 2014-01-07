library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity offsetter_s is
	port(
		PC:in std_logic_vector(31 downto 0);
		offset:in std_logic_vector(7 downto 0);
		NPC:out std_logic_vector(31 downto 0)
	);
end;

architecture main of offsetter_s is
begin

	NPC<=PC+offset;
	
end;
