library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity wm8731 is
	port(
		clk12:in std_logic;
		
		--FIFO RAM
		FIFO_empty:in std_logic;
		FIFO_clk,FIFO_en:out std_logic;
		FIFO_data:in std_logic_vector(15 downto 0);
		
		--I/O Port
		MCLK:out std_logic;
		BCLK,DACLRC:in std_logic;
		DACDAT:out std_logic;
		SCLK:out std_logic;
		SDIN:out std_logic
	);
end;

architecture main of wm8731 is

	component writer is
		port(
			datin:in std_logic_vector(15 downto 0);
			clk,we:in std_logic;
			done,noerr:out std_logic;
			
			SCLK:buffer std_logic:='1';
			SDIN:out std_logic:='1'
		);
	end component;

type stat_type is (set_power,set_freq,
					set_dio,clr_active,set_active,
					set_path,set_no_mute,
					wait_set,playing);
signal stat,nstat:stat_type:=set_power;

signal e1,e2,eb:std_logic;
signal we,done:std_logic:='0';
signal data:std_logic_vector(15 downto 0);

signal outofdata:std_logic;
signal i:integer range 15 downto 0;

begin
	
	u1:writer port map(datin=>data,clk=>clk12,we=>we,done=>done,
						SCLK=>SCLK,SDIN=>SDIN);
	
	MCLK<=clk12;
	
	process(clk12)
	begin
		if clk12'event and clk12='1' then
			case stat is
				when set_power=>
					data<="0000110000000111";
					we<='1';
					nstat<=set_freq;
					stat<=wait_set;
				
				when set_freq=>
					data<="0001000000000001";
					we<='1';
					nstat<=set_dio;
					stat<=wait_set;
				
				when set_dio=>
					data<="0000111001000010";
					we<='1';
					nstat<=set_path;
					stat<=wait_set;
				
				when set_path=>
					data<="0000100000010010";
					we<='1';
					nstat<=set_no_mute;
					stat<=wait_set;
				
				when set_no_mute=>
					data<="0000101000000110";
					we<='1';
					nstat<=clr_active;
					stat<=wait_set;
				
				when clr_active=>
					data<="0001001000000000";
					we<='1';
					nstat<=set_active;
					stat<=wait_set;
				
				when set_active=>
					data<="0001001000000001";
					we<='1';
					nstat<=playing;
					stat<=wait_set;
				
				when wait_set=>
					we<='0';
					if done='1' then
						stat<=nstat;
					end if;
				
				when playing=>
					we<='0';

			end case;
		end if;
	end process;
	
	process(DACLRC)
	begin
		if DACLRC'event and DACLRC='1' then
			e1<=not e1;
		end if;
	end process;
	
	process(DACLRC)
	begin
		if DACLRC'event and DACLRC='0' then
			e2<=not e2;
		end if;
	end process;
	
	FIFO_clk<=BCLK;
	process(BCLK)
	begin
		if BCLK'event and BCLK='0' then
			if (e1 xor e2 xor eb)='1' then
				eb<=e1 xor e2;
				if DACLRC='1' then
					FIFO_en<=not FIFO_empty;
					i<=15;
				else
					i<=i-1;
				end if;
				outofdata<='0';
			else
				DACDAT<=FIFO_data(i) and (not outofdata);
				FIFO_en<='0';
				if i=8 or i=0 then
					outofdata<='1';
				else
					i<=i-1;
				end if;
			end if;
		end if;
	end process;
	
end;
