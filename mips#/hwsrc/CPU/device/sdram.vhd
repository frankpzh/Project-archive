library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sdram is
	port(
		clk,clk_sdram,locked:in std_logic;
		
		we:in std_logic;
		addr:in std_logic_vector(31 downto 0);
		data:in std_logic_vector(15 downto 0);
		q:inout std_logic_vector(15 downto 0);
		busy:inout std_logic;
		
		SDRAM_CLK,SDRAM_CKE:out std_logic;
		SDRAM_CS_N,SDRAM_RAS_N,SDRAM_CAS_N,SDRAM_WE_N:out std_logic;
		SDRAM_DQ:inout std_logic_vector(15 downto 0);
		SDRAM_DQM:out std_logic_vector(1 downto 0);
		SDRAM_A:out std_logic_vector(11 downto 0);
		SDRAM_BA:out std_logic_vector(1 downto 0)
	);
end;

architecture main of sdram is

type stat_type is (	POWER,
					WAITING,
					PRECHARGE,
					FLASH,
					MODEREG,
					IDLE,
					FLASHONCE,
					ACT,
					READ,
					WRITE	);
signal stat:stat_type:=POWER;

signal rcw:std_logic_vector(2 downto 0);

signal cs,busy1,busy2:std_logic;
signal counter:std_logic_vector(14 downto 0);
signal smcount,waitcount:std_logic_vector(2 downto 0);

signal we_reg,realBusy:std_logic;
signal addr_reg:std_logic_vector(31 downto 0);
signal data_reg,q_reg:std_logic_vector(15 downto 0);

begin
	
	SDRAM_CLK<=clk_sdram;
	SDRAM_CKE<='1';
	SDRAM_CS_N<='0';
	SDRAM_BA<=addr_reg(21 downto 20);
	
	SDRAM_RAS_N<=rcw(2);
	SDRAM_CAS_N<=rcw(1);
	SDRAM_WE_N<=rcw(0);
	
	process(clk_sdram,locked)
	begin
		if locked='0' then
			counter<="101000000000000";
			SDRAM_DQM<="11";
			rcw<="111";												--NOP
			stat<=POWER;
		elsif clk_sdram'event and clk_sdram='0' then
			case stat is
				when POWER=>
					stat<=WAITING;
				when WAITING=>
					if counter="000000000000000" then
						rcw<="010";									--PALL
						stat<=PRECHARGE;
						smcount<="001";
					else
						counter<=counter-1;
					end if;
				when PRECHARGE=>
					if smcount="000" then
						rcw<="001";									--REF
						stat<=FLASH;
						smcount<="111";
						waitcount<="111";
					else
						rcw<="111";									--NOP
						smcount<=smcount-1;
					end if;
				when FLASH=>
					if waitcount="000" then
						if smcount="000" then
							rcw<="000";								--MRS
							SDRAM_A<="001000100000";
							counter<="000001100100000";
							stat<=MODEREG;
						else
							rcw<="001";								--REF
							waitcount<="111";
							smcount<=smcount-1;
						end if;
					else
						rcw<="111";									--NOP
						waitcount<=waitcount-1;
					end if;
				when MODEREG=>
					counter<=counter-1;
					SDRAM_DQM<="00";
					rcw<="111";										--NOP
					stat<=IDLE;
				when IDLE=>
					waitcount<="111";
					smcount<="001";
					SDRAM_A<=addr_reg(19 downto 8);
					
					if we_reg='1' then
						SDRAM_DQ<=data_reg;
					else
						SDRAM_DQ<=(others=>'Z');
					end if;
					
					if counter<"000000000001000" then
						rcw<="001";									--REF
						stat<=FLASHONCE;
					elsif (busy1 xor busy2)='1' then
						rcw<="011";									--ACT
						stat<=ACT;
					else
						rcw<="111";									--NOP
					end if;
					
					counter<=counter-1;
				when FLASHONCE=>
					rcw<="111";										--NOP
					if waitcount="000" then
						counter<="000000110010000";
						stat<=IDLE;
					end if;				
					waitcount<=waitcount-1;
				when ACT=>
					counter<=counter-1;
					SDRAM_A<="0100"&addr_reg(7 downto 0);
					if smcount="000" then
						if we='1' then
							smcount<="100";
							rcw<="100";								--WRITEA
							stat<=WRITE;
						else
							smcount<="011";
							rcw<="101";								--READA
							stat<=READ;
						end if;
					else
						rcw<="111";									--NOP
						smcount<=smcount-1;
					end if;
				when WRITE=>
					counter<=counter-1;
					smcount<=smcount-1;
					rcw<="111";										--NOP
					if smcount="000" then	
						busy2<=busy1;
						stat<=IDLE;
					end if;
				when READ=>
					counter<=counter-1;
					smcount<=smcount-1;
					rcw<="111";										--NOP
					if smcount="000" then	
						busy2<=busy1;
						q_reg<=SDRAM_DQ;
						stat<=IDLE;
					end if;
			end case;
		end if;
	end process;
	
	busy<=realBusy when cs='1' else 'Z';
	q<=q_reg when cs='1' else (others=>'Z');
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if addr(31 downto 22)="000000001" then
				if realBusy='0' then
					busy1<=not busy2;
					addr_reg<=addr;
					data_reg<=data;
					we_reg<=we;
					realBusy<='1';
				else
					realBusy<=busy1 xor busy2;
				end if;
				cs<='1';
			else
				realBusy<=busy1 xor busy2;
				cs<='0';
			end if;
		end if;
	end process;

end;