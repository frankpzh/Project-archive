library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity wm8731_ctrl is
	port(
		clk:in std_logic;
		
		datin:in std_logic_vector(15 downto 0);
		enable,clkout,bigclk:buffer std_logic;
		command:in std_logic_vector(3 downto 0);
		
		MCLK:out std_logic;
		BCLK,DACLRC:in std_logic;
		DACDAT:out std_logic;
		SCLK:out std_logic;
		SDIN:inout std_logic
	);
end;

architecture main of wm8731_ctrl is

	component writer is
		port(
			datin:in std_logic_vector(15 downto 0);
			clk,we:in std_logic;
			done,noerr:out std_logic;
			
			SCLK:buffer std_logic:='1';
			SDIN:inout std_logic:='1'
		);
	end component;

	COMPONENT pll IS
		PORT
		(
			inclk0	: IN STD_LOGIC:='0';
			c0		: OUT STD_LOGIC 
		);
	END component;

	COMPONENT split5 IS
		PORT
		(
			inclk	: IN STD_LOGIC;
			outclk	: OUT STD_LOGIC 
		);
	END component;

type stat_type is (set_power,set_freq,
					set_dio,clr_active,set_active,
					set_path,set_no_mute,
					wait_set,playing,
					setvolume,setvolume1);

signal stat,nstat:stat_type:=set_power;

signal e1,e2,eb:std_logic;

signal we,done:std_logic:='0';
signal data:std_logic_vector(15 downto 0);
signal datin_buf:std_logic_vector(15 downto 0);

signal volume:std_logic_vector(6 downto 0):="1111001";

begin
	
	u1:writer port map(datin=>data,clk=>clk,we=>we,done=>done,
						SCLK=>SCLK,SDIN=>SDIN);
	
	u2:pll port map(inclk0=>clk,c0=>clkout);
	
	u3:split5 port map(inclk=>clkout,outclk=>MCLK);
	
	bigclk<=DACLRC;
	
	process(clk)
	begin
		if clk'event and clk='1' then
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
					if command="0001" then
						if volume<"1111111" then
							volume<=volume+1;
						end if;
						stat<=setvolume;
					elsif command="0010" then
						if volume>"0101111" then
							volume<=volume-1;
						end if;
						stat<=setvolume;
					end if;
					we<='0';
					
				when setvolume=>
					data<="000001000"&volume;
					we<='1';
					nstat<=setvolume1;
					stat<=wait_set;

				when setvolume1=>
					data<="000001100"&volume;
					we<='1';
					nstat<=playing;
					stat<=wait_set;

			end case;
		end if;
	end process;
	
	enable<='1' when stat=playing else '0';
	
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
	
	process(BCLK,e1,e2)
	variable i:integer range 0 to 16;
	begin
		if (e1 xor e2 xor eb)='1' then
			eb<=e1 xor e2;
			datin_buf<=datin;
			i:=16;
		elsif BCLK'event and BCLK='0' then
			if i>0 then
				i:=i-1;
				DACDAT<=datin_buf(i);
			end if;
		end if;
	end process;
	
end;
