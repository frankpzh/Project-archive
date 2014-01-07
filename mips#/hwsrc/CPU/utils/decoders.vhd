library ieee;
use ieee.std_logic_1164.all;

entity decoders is
	port (
		PC:in std_logic_vector(31 downto 0);
		HEX:out std_logic_vector(27 downto 0)
	);
end;

architecture main of decoders is
	component decoder is
		port(
			bits:in std_logic_vector(3 downto 0);
			seven:out std_logic_vector(6 downto 0)
		);
	end component;
begin
	u0:decoder port map(bits=>PC(15 downto 12),seven=>HEX(27 downto 21));
	u1:decoder port map(bits=>PC(11 downto 8),seven=>HEX(20 downto 14));
	u2:decoder port map(bits=>PC(7 downto 4),seven=>HEX(13 downto 7));
	u3:decoder port map(bits=>PC(3 downto 0),seven=>HEX(6 downto 0));
end;