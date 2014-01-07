library ieee;
use ieee.std_logic_1164.all;

entity wall2 is
	port(
		clk,door2,door2_clr:in std_logic;
		
		CU_dest:in std_logic_vector(2 downto 0);
		CU_A,CU_B:in std_logic_vector(15 downto 0);
		CU_sign:in std_logic_vector(3 downto 0);
		Loopback_ALU_dest:in std_logic_vector(1 downto 0);
		ALU_dest:out std_logic_vector(2 downto 0);
		ALU_A,ALU_B:out std_logic_vector(15 downto 0);
		ALU_sign:out std_logic_vector(3 downto 0):="0000";
		Loopback_ALU_dest_out:out std_logic_vector(1 downto 0);
		
		C_alu:in std_logic;
		C_cu:out std_logic;
		
		CU_reg:in std_logic_vector(2 downto 0);
		CU_data:in std_logic_vector(15 downto 0);
		CU_addr:in std_logic_vector(31 downto 0);
		CU_we,CU_cs:in std_logic;
		Loopback_MC_en:in std_logic;
		MC_reg:out std_logic_vector(2 downto 0);
		MC_data:out std_logic_vector(15 downto 0);
		MC_addr:out std_logic_vector(31 downto 0);
		MC_we,MC_cs:out std_logic:='0';
		Loopback_MC_en_out:out std_logic
	);
end;

architecture main of wall2 is
begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if door2='1' then
				ALU_dest<=CU_dest;
				ALU_A<=CU_A;
				ALU_B<=CU_B;
				ALU_sign<=CU_sign;
				Loopback_ALU_dest_out<=Loopback_ALU_dest;
				
				MC_reg<=CU_reg;
				MC_data<=CU_data;
				MC_addr<=CU_addr;
				MC_we<=CU_we;
				MC_cs<=CU_cs;
				Loopback_MC_en_out<=Loopback_MC_en;
			else
				ALU_sign<="1111";
				if door2_clr='1' then
					MC_cs<='0';
				end if;
			end if;
		end if;
	end process;
	
	C_cu<=C_alu;
	
end;