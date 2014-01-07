library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity wm8731 is
	port(
		clk24:in std_logic;
		
		--DATA OUT
		CLK48:out std_logic;
		DATAOUT:out std_logic_vector(15 downto 0);
		
		--I/O Port
		MCLK:out std_logic;
		BCLK,ADCLRC,ADCDAT:in std_logic;
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
					set_dio,clr_active,
					set_path,set_active,
					set_no_mutel,set_no_muter,
					wait_set,playing);
signal stat,nstat:stat_type:=set_power;

signal clk12,e1,eb:std_logic;
signal we,done:std_logic:='0';
signal data:std_logic_vector(15 downto 0);

signal i:integer range 15 downto -1;

begin
	
	process(clk24)
	begin
		if clk24'event and clk24='1' then
			clk12<=not clk12;
		end if;
	end process;
	
	u1:writer port map(datin=>data,clk=>clk12,we=>we,done=>done,
						SCLK=>SCLK,SDIN=>SDIN);
	
	MCLK<=clk12;
	
	process(clk12)
	begin
		if clk12'event and clk12='1' then
			case stat is
				when set_power=>
					data<="0000110000000000";
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
					data<="0000100000000101";
					we<='1';
					nstat<=set_no_mutel;
					stat<=wait_set;
				
				when set_no_mutel=>
					data<="0000000000010111";
					we<='1';
					nstat<=set_no_muter;
					stat<=wait_set;
				
				when set_no_muter=>
					data<="0000001000010111";
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
	
	CLK48<=ADCLRC;
	process(ADCLRC)
	begin
		if ADCLRC'event and ADCLRC='1' then
			e1<=not eb;
		end if;
	end process;
	
	process(BCLK)
	begin
		if BCLK'event and BCLK='0' then
			if (e1 xor eb)='1' then
				eb<=e1;
				i<=15;
			else
				if not(i=-1) then
					DATAOUT(i)<=ADCDAT;
					i<=i-1;
				end if;
			end if;
		end if;
	end process;
	
end;
