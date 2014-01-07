library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram_writer is
	port(
		step,reset:in std_logic;
		in_data:in std_logic_vector(15 downto 0);
		out_data:out std_logic_vector(27 downto 0);
		
		out_addr:out std_logic_vector(27 downto 0);
		
		SRAM_addr:out std_logic_vector(17 downto 0);
		SRAM_data:out std_logic_vector(15 downto 0);
		SRAM_q:in std_logic_vector(15 downto 0);
		SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:out std_logic		
	);
end;

architecture main of ram_writer is

component decoder is
	port(
		bits:in std_logic_vector(3 downto 0);
		seven:out std_logic_vector(6 downto 0)
	);
end component;

signal addr:std_logic_vector(17 downto 0):=(others=>'0');

begin
	
	u1:decoder port map(bits=>in_data(3 downto 0),seven=>out_data(6 downto 0));
	u2:decoder port map(bits=>in_data(7 downto 4),seven=>out_data(13 downto 7));
	u3:decoder port map(bits=>in_data(11 downto 8),seven=>out_data(20 downto 14));
	u4:decoder port map(bits=>in_data(15 downto 12),seven=>out_data(27 downto 21));
	
	u5:decoder port map(bits=>addr(3 downto 0),seven=>out_addr(6 downto 0));
	u6:decoder port map(bits=>addr(7 downto 4),seven=>out_addr(13 downto 7));
	u7:decoder port map(bits=>addr(11 downto 8),seven=>out_addr(20 downto 14));
	u8:decoder port map(bits=>addr(15 downto 12),seven=>out_addr(27 downto 21));
	
	SRAM_addr<=addr;
	SRAM_data<=in_data;
	SRAM_n_we<='0';
	SRAM_n_oe<='1';
	SRAM_n_ub<='0';
	SRAM_n_lb<='0';
	SRAM_n_ce<='0';
	
	process(step,reset)
	begin
		if reset='0' then
			addr<=(others=>'0');
		else
			if step'event and step='0' then
				addr<=addr+1;
			end if;
		end if;
	end process;
	
end;