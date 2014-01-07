library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sdcard is
	port(
		clk:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--Buffer
		BUF_clk,BUF_we:out std_logic:='0';
		BUF_addr:buffer std_logic_vector(8 downto 0);
		BUF_data:out std_logic_vector(7 downto 0);
		
		--SD Card
		SD_CS,SD_DI,SD_SCLK:buffer std_logic;
		SD_DO:in std_logic
	);
end;

architecture main of sdcard is

type stat_type is (idle,send_com,resp,respb,wait_resp,wait_respb,
					wait_busy,read1,read2,read3);
signal stat:stat_type:=idle;

signal q:std_logic_vector(15 downto 0);
signal cs,busy1,busy2,busy_on_rising:std_logic:='0';

signal sd_busy,sd_valid:std_logic;
signal resps:std_logic_vector(39 downto 0);
signal command:std_logic_vector(47 downto 0);
signal cmd_detail:std_logic_vector(3 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr(31 downto 3)="00000000100001000000010100000" then
				cs<='1';
				if BUS_we='1' and BUS_addr(2)='0' then
					case BUS_addr(1 downto 0) is
					when "00"=>
						command(15 downto 0)<=BUS_data;
					when "01"=>
						command(31 downto 16)<=BUS_data;
					when "10"=>
						command(47 downto 32)<=BUS_data;
					when "11"=>
						cmd_detail<=BUS_data(3 downto 0);
					end case;
				end if;
				if BUS_addr(2 downto 0)="111" and busy_on_rising='0' then
					busy1<=not busy2;
				end if;
			else
				cs<='0';
			end if;
		end if;
	end process;
	
	BUS_busy<=busy1 xor busy2 when cs='1' else 'Z';
	BUS_q<=q when cs='1' else (others=>'Z');
	
	process(clk)
	begin
		if clk'event and clk='0' then
			busy_on_rising<=(busy1 xor busy2) and cs;
		end if;
	end process;
	
	with BUS_addr(2 downto 0) select
	q<=	command(15 downto 0)					when "000",
		command(31 downto 16)					when "001",
		command(47 downto 32)					when "010",
		"000000000000"&cmd_detail				when "011",
		resps(15 downto 0)						when "100",
		resps(31 downto 16)						when "101",
		"0000000"&sd_busy&resps(39 downto 32)	when "110",
		"000000000000000"&sd_valid				when "111";
	
	SD_CS<='0';
	SD_SCLK<=not clk;
	BUF_clk<=not clk;
	
	process(SD_SCLK)
	variable i:integer range 48 downto 0;
	variable j:integer range 70 downto 0;
	begin
		if SD_SCLK'event and SD_SCLK='0' then
			case stat is
			when idle=>
				SD_DI<='1';
				BUF_we<='0';
				if (busy1 xor busy2)='1' then
					stat<=send_com;
					i:=48;
				end if;
			when send_com=>
				i:=i-1;
				SD_DI<=command(i);
				if i=0 then
					j:=70;
					case cmd_detail(1 downto 0) is
					when "00"=>		--resp_r1
						i:=7;
						stat<=wait_resp;
					when "01"=>		--resp_r1b
						i:=7;
						stat<=wait_respb;
					when "10"=>		--resp_r2
						i:=15;
						stat<=wait_resp;
					when "11"=>		--resp_r3
						i:=39;
						stat<=wait_resp;
					end case;
				end if;
			when wait_resp=>
				resps(i)<=SD_DO;
				j:=j-1;
				if SD_DO='0' then
					stat<=resp;
				elsif j=0 then
					busy2<=busy1;
					sd_valid<='0';
					sd_busy<='0';
					stat<=idle;
				end if;
			when wait_respb=>
				resps(i)<=SD_DO;
				j:=j-1;
				if SD_DO='0' then
					stat<=respb;
				elsif j=0 then
					busy2<=busy1;
					sd_valid<='0';
					sd_busy<='0';
					stat<=idle;
				end if;
			when resp=>
				i:=i-1;
				resps(i)<=SD_DO;
				if i=0 then
					if (cmd_detail(3 downto 2)="01") and
						(resps(6 downto 1)&SD_DO="0000000") then
						stat<=read1;
					else
						busy2<=busy1;
						sd_valid<='1';
						sd_busy<='0';
						stat<=idle;
					end if;
				end if;
			when respb=>
				i:=i-1;
				resps(i)<=SD_DO;
				if i=0 then
					busy2<=busy1;
					sd_valid<='1';
					sd_busy<='1';
					stat<=wait_busy;
				end if;
			when wait_busy=>
				sd_busy<=not SD_DO;
				if SD_DO='1' then
					stat<=idle;
				end if;
			when read1=>
				if SD_DO='0' then
					i:=8;
					BUF_addr<=(others=>'1');
					stat<=read2;
				end if;
			when read2=>
				i:=i-1;
				BUF_data(i)<=SD_DO;
				if i=0 then
					BUF_we<='1';
					BUF_addr<=BUF_addr+1;
					if BUF_addr="111111110" then
						i:=16;
						stat<=read3;
					else
						i:=8;
					end if;
				else
					BUF_we<='0';
				end if;
			when read3=>
				BUF_we<='0';
				i:=i-1;
				if i=0 then
					busy2<=busy1;
					sd_valid<='1';
					sd_busy<='0';
					stat<=idle;
				end if;
			end case;
		end if;
	end process;
	
end;