library ieee;
use ieee.std_logic_1164.all;

entity decoder8 is
	port (
		NUM:in std_logic_vector(7 downto 0);
		HEX:out std_logic_vector(13 downto 0)
	);
end;

architecture main of decoder8 is
	component decoder is
		port(
			bits:in std_logic_vector(3 downto 0);
			seven:out std_logic_vector(6 downto 0)
		);
	end component;
begin
	u2:decoder port map(bits=>NUM(7 downto 4),seven=>HEX(13 downto 7));
	u3:decoder port map(bits=>NUM(3 downto 0),seven=>HEX(6 downto 0));
end;