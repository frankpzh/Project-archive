library ieee;
use ieee.std_logic_1164.all;

entity SRAM_ctrl is
	port(
		clk:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--OUT
		SRAM_addr:out std_logic_vector(17 downto 0);
		SRAM_data:inout std_logic_vector(15 downto 0);
		SRAM_q:in std_logic_vector(15 downto 0);
		SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:buffer std_logic
	);
end;

architecture main of SRAM_ctrl is

signal SRAM_cs_n:std_logic;

begin
	
	SRAM_cs_n<='0' when BUS_addr(31 downto 18)="00000000100000" else '1';
	SRAM_n_ub<='0';
	SRAM_n_lb<='0';
	
	process(clk) is
	begin
		if clk'event and clk='0' then
			SRAM_n_ce<=SRAM_cs_n;
			SRAM_n_we<=not BUS_we;
			SRAM_n_oe<=BUS_we;
			SRAM_addr<=BUS_addr(17 downto 0);
			if BUS_we='1' then
				SRAM_data<=BUS_data;
			else
				SRAM_data<=(others=>'Z');
			end if;
		end if;
	end process;
	
	BUS_q<=SRAM_data when SRAM_cs_n='0' else (others=>'Z');
	BUS_busy<='0' when SRAM_cs_n='0' else 'Z';
	
end;