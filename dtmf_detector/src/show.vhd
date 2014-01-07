library ieee;
use ieee.std_logic_1164.all;

entity show is
	port(
		clk:in std_logic;
		data:in std_logic_vector(3 downto 0);
		hex:out std_logic_vector(27 downto 0)
	);
end;

architecture main of show is

	component decoder is
		port(
			bits:in std_logic_vector(3 downto 0);
			seven:out std_logic_vector(6 downto 0)
		);
	end component;

signal last:std_logic_vector(3 downto 0);
signal queue:std_logic_vector(15 downto 0):=(others=>'0');

begin
	
	process(clk)
	begin
		if clk'event and clk='0' then
			if last="1111" and not (data="1111") then
				queue(15 downto 12)<=queue(11 downto 8);
				queue(11 downto 8)<=queue(7 downto 4);
				queue(7 downto 4)<=queue(3 downto 0);
				queue(3 downto 0)<=data;
			end if;
			last<=data;
		end if;
	end process;
	
	u0:decoder port map(bits=>queue(3 downto 0),seven=>hex(6 downto 0));
	u1:decoder port map(bits=>queue(7 downto 4),seven=>hex(13 downto 7));
	u2:decoder port map(bits=>queue(11 downto 8),seven=>hex(20 downto 14));
	u3:decoder port map(bits=>queue(15 downto 12),seven=>hex(27 downto 21));
	
end;