library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity offsetter_5 is
	port(
		PC:in std_logic_vector(15 downto 0);
		offset:in std_logic_vector(4 downto 0);
		NPC:out std_logic_vector(15 downto 0)
	);
end;

architecture main of offsetter_5 is
begin

	NPC<=PC(15 downto 0)+offset;
	
end;
