library ieee;
use ieee.std_logic_1164.all;

--Bus Controller
entity bc is
	PORT(
		clk,reset_n:in std_logic;
		
		--MC
		MC_cs,MC_we:in std_logic;
		MC_data:in STD_LOGIC_VECTOR (15 DOWNTO 0);
		MC_q:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		MC_addr:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		MC_busy:out std_logic;

		--CC
		CC_cs:in std_logic;
		CC_q:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		CC_addr:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		CC_busy:out std_logic;
		
		--BUS
		BUS_we:out std_logic;
		BUS_addr:out std_logic_vector(31 downto 0);
		BUS_data:out std_logic_vector(15 downto 0);
		BUS_q:in std_logic_vector(15 downto 0);
		BUS_busy:in std_logic
	);
end;

architecture main of bc is
type stat_type is (idle, wait_mem, wait_cache);
signal stat:stat_type:=idle;
begin
	
	process(reset_n,clk)
	begin
		if reset_n='0' then
			stat<=idle;
			CC_busy<='1';
			MC_busy<='1';
			BUS_addr<=(others=>'1');
		elsif clk'event and clk='0' then
			case stat is
			when idle=>
				CC_busy<=CC_cs;
				MC_busy<=MC_cs;
				if CC_cs='1' then
					BUS_addr<=CC_addr;
					BUS_we<='0';
					stat<=wait_cache;
				elsif MC_cs='1' then
					BUS_addr<=MC_addr;
					BUS_data<=MC_data;
					BUS_we<=MC_we;
					stat<=wait_mem;
				else
					BUS_addr<=(others=>'1');
				end if;
			when wait_cache=>
				MC_busy<=MC_cs;
				if BUS_busy='0' then
					CC_q<=BUS_q;
					CC_busy<='0';
					BUS_addr<=(others=>'1');
					stat<=idle;
				end if;
			when wait_mem=>
				CC_busy<=CC_cs;
				if BUS_busy='0' then
					MC_q<=BUS_q;
					MC_busy<='0';
					BUS_addr<=(others=>'1');
					stat<=idle;
				end if;
			end case;
		end if;
	end process;
	
end;