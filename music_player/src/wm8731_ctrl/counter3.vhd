library ieee;
use ieee.std_logic_1164.all;

entity counter3 is
	port (
		clear,clk:in std_logic;
		q:buffer std_logic_vector(2 downto 0)
	);
end;

architecture main of counter3 is
	component syncff is
		port (
			D:in std_logic;
			last:in std_logic;
			clk:in std_logic;
			clr:in std_logic;
			Q:out std_logic
		);
	end component;
	
begin

	u1:syncff port map (Q=>q(0),D=>not q(0),last=>'1',clk=>clk,clr=>clear);
	u2:syncff port map (Q=>q(1),D=>not q(1),last=>q(0),clk=>clk,clr=>clear);
	u3:syncff port map (Q=>q(2),D=>not q(2),last=>q(1) and q(0),clk=>clk,clr=>clear);
	
end;