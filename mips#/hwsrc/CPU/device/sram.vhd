library ieee;
use ieee.std_logic_1164.all;

entity sram is
	port (
		clk,clk_sram:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--LCD
		read_addr:in std_logic_vector(17 downto 0);
		read_q:out std_logic_vector(15 downto 0);
		
		--OUT
		sram_addr:out std_logic_vector(17 downto 0);
		sram_data:inout std_logic_vector(15 downto 0);
		sram_we_n,sram_oe_n,sram_ub_n,sram_lb_n,sram_ce_n:out std_logic
	);
end;

architecture main of sram is
signal clk_half,cs_n,busy1,busy2:std_logic;
signal busy1a,busy2a,busy1b,busy2b,busyreg:std_logic:='0';

signal BUS_we_reg,realBusy:std_logic;
signal BUS_q_reg:std_logic_vector(15 downto 0);
signal BUS_addr_reg:std_logic_vector(31 downto 0);
signal BUS_data_reg:std_logic_vector(15 downto 0);
begin
	
	process(clk_sram)
	begin
		if clk_sram'event and clk_sram='1' then
			clk_half<=not clk_half;
		end if;
	end process;
	
	sram_lb_n<='0';
	sram_ub_n<='0';
	
	process(clk_sram)
	begin
		if clk_sram'event and clk_sram='1' then
			if clk_half='1' then
				BUS_q_reg<=sram_data;
				if busy1='0' then
					busy2b<=busy2a;
				end if;
				
				sram_ce_n<='0';
				sram_addr<=read_addr;
				sram_we_n<='1';
				sram_oe_n<='0';
				sram_data<=(others=>'Z');
			else
				read_q<=sram_data;
				
				sram_ce_n<=cs_n;
				sram_addr<=BUS_addr_reg(17 downto 0);
				sram_we_n<=not BUS_we_reg;
				sram_oe_n<=BUS_we_reg;
				if BUS_we_reg='1' then
					sram_data<=BUS_data_reg;
				else
					sram_data<=(others=>'Z');
				end if;
				busy1b<=busy1a;
			end if;
		end if;
	end process;
	
	BUS_q<=BUS_q_reg when cs_n='0' else (others=>'Z');
	BUS_busy<=realBusy when cs_n='0' else 'Z';
	busy1<=busy1a xor busy1b;
	busy2<=busy2a xor busy2b;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr(31 downto 18)="00000000100000" then
				if realBusy='0' then
					busy1a<=not busy1b;
					busy2a<=not busy2b;
					BUS_addr_reg<=BUS_addr;
					BUS_data_reg<=BUS_data;
					BUS_we_reg<=BUS_we;
					realBusy<='1';
				else
					realBusy<=busy1 or busy2;
				end if;
				cs_n<='0';
			else
				cs_n<='1';
			end if;
		end if;
	end process;
	
end;