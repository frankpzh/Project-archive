library ieee;
use ieee.std_logic_1164.all;

--Memory Control
entity mc is
	port(
		--CU
		CU_cs,CU_we:in std_logic;
		CU_reg:in STD_LOGIC_VECTOR (2 DOWNTO 0);
		CU_addr:in STD_LOGIC_VECTOR (31 DOWNTO 0);
		CU_data:in STD_LOGIC_VECTOR (15 DOWNTO 0);
		Loopback_en:in std_logic;
		
		--BC
		BUS_cs,BUS_we:buffer std_logic;
		BUS_addr:out std_logic_vector(31 downto 0);
		BUS_data:out std_logic_vector(15 downto 0);
		BUS_busy:in std_logic;
		BUS_q:in std_logic_vector(15 downto 0);
		
		--FCRH
		REG_last:in std_logic_vector(15 downto 0);
		MC_busy:out std_logic;
		REG_id:out std_logic_vector(2 downto 0);
		REG_in:out std_logic_vector(15 downto 0);
		REG_en:out std_logic
	);
end;

architecture main of mc is
begin
	
	BUS_cs<=CU_cs;
	BUS_we<=CU_we;
	BUS_addr<=CU_addr;
	BUS_data<=REG_last when Loopback_en='1' else CU_data;
	
	REG_id<=CU_reg;
	REG_in<=BUS_q;
	REG_en<=not(BUS_busy or CU_we) and CU_cs;
	
	MC_busy<=BUS_busy and CU_cs;
	
end;