library ieee;
use ieee.std_logic_1164.all;

entity split5 is
	port (
		inclk:in std_logic;
		outclk:out std_logic
	);
end;

architecture main of split5 is

	component counter3 is
		port (
			clear,clk:in std_logic;
			q:out std_logic_vector(2 downto 0)
		);
	end component;
	
signal clr,clr1,clr2:std_logic;
signal output:std_logic_vector(2 downto 0);

begin

	--生成扬声器信号
	outclk<='0' when output<"010" else '1';
	
	process(inclk)
	begin
		if inclk'event and inclk='0' then--上升沿
			if output="100" then 
				clr1<='1';
			else
				clr1<='0';
			end if;
		end if;
	end process;
	
	process(inclk)
	begin
		if inclk'event and inclk='1' then--下降沿
			clr2<=not clr1;
		end if;
	end process;

	--16位计数器
	u0:counter3 port map (clear=>clr1 and clr2,clk=>inclk,q=>output);
	
end;