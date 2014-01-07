library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity player is
	port (
		clk,reset:in std_logic;
		
		KCLK,KDAT:in std_logic;
		time:buffer std_logic_vector(31 downto 0);
		
		DATAOUT:in std_logic;
		CS,DATAIN:out std_logic;
		CLK_sd:buffer std_logic;
				
		clk_vga:buffer std_logic;
		BPb,RPr,GY:out std_logic_vector(7 downto 0);
		HS,VS,SYNC,BLANK:out std_logic;
		
		BCLK,DACLRC:in std_logic;
		MCLK,DACDAT,SCLK:out std_logic;
		SDIN:inout std_logic
	);
end;

architecture main of player is

	component sd_control is
		port(
			DATAOUT:in std_logic;
			CS,DATAIN:out std_logic;
			CLK:out std_logic;
			
			ready:out std_logic;
			command:in std_logic_vector(17 downto 0);
			SpC:out std_logic_vector(7 downto 0);
			
			wren:out std_logic;
			add_file:out std_logic_vector(8 downto 0);
			data_file:out std_logic_vector(7 downto 0);
			out_file:in std_logic_vector(7 downto 0);

			clkin,reset:in std_logic
		);
	end component;

	component wm8731_ctrl is
		port (
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
	end component;

	component musicreader is
		port (
			clk,bigclk,reset,enable:in std_logic;
			
			add_file:buffer std_logic_vector(7 downto 0);
			out_file:in std_logic_vector(31 downto 0);
			
			tout:buffer std_logic_vector(31 downto 0);
			
			add_note:buffer std_logic_vector(6 downto 0);
			data_note:out std_logic_vector(31 downto 0);
			out_note:in std_logic_vector(31 downto 0);
			wren_note:out std_logic
		);
	end component;
	
	component musicmixer is
		port (
			clk,bigclk,reset:in std_logic;
			
			add_note:out std_logic_vector(6 downto 0);
			data_note:out std_logic_vector(31 downto 0);
			out_note:in std_logic_vector(31 downto 0);
			wren:out std_logic;
			
			output:out std_logic_vector(15 downto 0)
		);
	end component;
	
	component vga_ctrl is
		port(
			clk:in std_logic;
			menu_pos:in std_logic_vector(4 downto 0);
			special:in std_logic_vector(3 downto 0);
			progress:in std_logic_vector(7 downto 0);
			
			add_console:out std_logic_vector(10 downto 0);
			out_console:in std_logic_vector(7 downto 0);
			
			BPb,RPr,GY:out std_logic_vector(7 downto 0);
			SYNC,BLANK,HS,VS,clk_vga:buffer std_logic
		);
	end component;
	
	component keyboard_ctrl is
		port(
			reset,clk:in std_logic;
			
			KCLK,KDAT:in std_logic;
			up,down,left,enter,pgup,pgdown:out std_logic
		);
	end component;
	
	COMPONENT note_ram IS
		PORT
		(
			address_a	: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
			address_b	: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			data_a		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			wren_a		: IN STD_LOGIC  := '1';
			wren_b		: IN STD_LOGIC  := '1';
			q_a			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			q_b			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT file_ram IS
		PORT
		(
			address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			address_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock_a		: IN STD_LOGIC ;
			clock_b		: IN STD_LOGIC ;
			data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			wren_a		: IN STD_LOGIC  := '1';
			wren_b		: IN STD_LOGIC  := '1';
			q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			q_b		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT console_ram IS
		PORT
		(
			address_a		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			address_b		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			clock_a		: IN STD_LOGIC ;
			clock_b		: IN STD_LOGIC ;
			data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wren_a		: IN STD_LOGIC  := '1';
			wren_b		: IN STD_LOGIC  := '1';
			q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT sd_ram IS
		PORT
		(
			address_a		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			address_b		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			clock_a		: IN STD_LOGIC ;
			clock_b		: IN STD_LOGIC ;
			data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wren_a		: IN STD_LOGIC  := '1';
			wren_b		: IN STD_LOGIC  := '1';
			q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;

	component file_ctrl is
		port (
			clk:in std_logic;
			
			command:in std_logic_vector(7 downto 0);
			done:out std_logic;
			
			add_file:out std_logic_vector(9 downto 0);
			data_file:out std_logic_vector(7 downto 0);
			q_file:in std_logic_vector(7 downto 0);
			wren_file:out std_logic:='0';
			
			add_sd:out std_logic_vector(8 downto 0);
			q_sd:in std_logic_vector(7 downto 0);
			
			cmd_to_sd:out std_logic_vector(17 downto 0);
			ready_sd:in std_logic;
			SpC:in std_logic_vector(7 downto 0)
		);
	end component;

	component console_ctrl is
		port (
			clk:in std_logic;
			
			add_file:buffer std_logic_vector(7 downto 0);
			q_file:in std_logic_vector(31 downto 0);
			stat_main:in std_logic_vector(4 downto 0);
			
			add_console:buffer std_logic_vector(10 downto 0);
			data_console:out std_logic_vector(7 downto 0);
			q_console:in std_logic_vector(7 downto 0);
			wren_console:out std_logic:='0'
		);
	end component;

	component wavereader is
		port (
			clk,bigclk,enable:in std_logic;
			finish:out std_logic;
			add:buffer std_logic_vector(7 downto 0);
			q:in std_logic_vector(31 downto 0);
			
			progress:out std_logic_vector(7 downto 0);
			output:out std_logic_vector(15 downto 0)
		);
	end component;

type stat_type is (init,wait_done,wait_file,mainmenu,
					select_mid,select_wav,about,
					play_mid,play_wav,wait_wm8731);

signal stat,nstat:stat_type:=init;

--60MHz and 48kHz
signal clock,bigclk:std_logic;

--Music Reader <--> Note RAM
signal add_a:std_logic_vector(6 downto 0);
signal data_a:std_logic_vector(31 downto 0);
signal q_a:std_logic_vector(31 downto 0);
signal wren_a:std_logic;

--Music Mixer <--> Note RAM
signal add_b:std_logic_vector(6 downto 0);
signal data_b:std_logic_vector(31 downto 0);
signal q_b:std_logic_vector(31 downto 0);
signal wren_b:std_logic;

--Music Reader/Wave Reader/Console Control <--> File RAM
signal add_c:std_logic_vector(7 downto 0);
signal q_c:std_logic_vector(31 downto 0);

--File Control <--> File RAM
signal add_d:std_logic_vector(9 downto 0);
signal data_d:std_logic_vector(7 downto 0);
signal q_d:std_logic_vector(7 downto 0);
signal wren_d:std_logic;

--File Control <--> SD Card RAM
signal add_e:std_logic_vector(8 downto 0);
signal q_e:std_logic_vector(7 downto 0);

--SD Card Control <--> SD Card RAM
signal add_f:std_logic_vector(8 downto 0);
signal data_f:std_logic_vector(7 downto 0);
signal q_f:std_logic_vector(7 downto 0);
signal wren_f:std_logic;

--Console Control <--> Console RAM
signal add_g:std_logic_vector(10 downto 0);
signal data_g:std_logic_vector(7 downto 0);
signal q_g:std_logic_vector(7 downto 0);
signal wren_g:std_logic;

--VGA Control <--> Console RAM
signal add_console:std_logic_vector(10 downto 0);
signal out_console:std_logic_vector(7 downto 0);

--File RAM Switch
type sw_type is (console,wav,mid);
signal switcher:sw_type:=console;

--File RAM Switch --> MIDI
signal enable_mid:std_logic;
signal reset_mid:std_logic;
signal add_c_mid:std_logic_vector(7 downto 0);
signal output_mid:std_logic_vector(15 downto 0);

--File RAM Switch --> WAVE
signal progress:std_logic_vector(7 downto 0);
signal enable_wav,finish_wav:std_logic;
signal add_c_wav:std_logic_vector(7 downto 0);
signal output_wav:std_logic_vector(15 downto 0);

--File RAM Switch --> Console Control
signal stat_console:std_logic_vector(4 downto 0);
signal add_c_console:std_logic_vector(7 downto 0);

--WM8731 Control
signal done_wm8731:std_logic;
signal output:std_logic_vector(15 downto 0);
signal command_wm8731:std_logic_vector(3 downto 0);

--SD Card Control
signal reset_sd,ready_sd:std_logic;
signal cmd_sd:std_logic_vector(17 downto 0);
signal SpC:std_logic_vector(7 downto 0);

--VGA Control
signal oldup,olddown,oldleft,oldenter,oldpgup,oldpgdown:std_logic;
signal menu_pos:std_logic_vector(4 downto 0);
signal special:std_logic_vector(3 downto 0);

--File Control
signal cmd_file:std_logic_vector(7 downto 0);
signal done_file:std_logic;

--File Page Down
signal now_page:std_logic;

--Keyboard Control
signal up,down,left,enter,pgup,pgdown:std_logic;

begin

	u1:wm8731_ctrl port map(clk=>clk,command=>command_wm8731,clkout=>clock,bigclk=>bigclk,
						MCLK=>MCLK,BCLK=>BCLK,DACLRC=>DACLRC,DACDAT=>DACDAT,
						SCLK=>SCLK,SDIN=>SDIN,datin=>output,enable=>done_wm8731);
						
	u2:musicreader port map(add_note=>add_a,data_note=>data_a,out_note=>q_a,
						wren_note=>wren_a,clk=>clock,bigclk=>bigclk,reset=>reset_mid,
						add_file=>add_c_mid,out_file=>q_c,tout=>time,enable=>enable_mid);
						
	u3:musicmixer port map(add_note=>add_b,out_note=>q_b,data_note=>data_b,wren=>wren_b,
						clk=>clock,bigclk=>not bigclk,output=>output_mid,reset=>reset_mid);
			
	u4:vga_ctrl port map(clk=>clk,add_console=>add_console,out_console=>out_console,
						BPb=>BPb,RPr=>RPr,GY=>GY,SYNC=>SYNC,BLANK=>BLANK,
						HS=>HS,VS=>VS,clk_vga=>clk_vga,menu_pos=>menu_pos,
						special=>special,progress=>progress);
	
	u5:note_ram port map(address_a=>add_a,data_a=>data_a,wren_a=>wren_a,q_a=>q_a,
						address_b=>add_b,data_b=>data_b,wren_b=>wren_b,q_b=>q_b,
						clock=>clock);
	
	u6:console_ram port map(clock_a=>not clk_vga,clock_b=>not clk,
						wren_a=>'0',wren_b=>wren_g,
						address_a=>add_console,address_b=>add_g,
						data_a=>(others=>'0'),data_b=>data_g,
						q_a=>out_console,q_b=>q_g);
	
	u7:file_ram port map(clock_a=>not clk,clock_b=>not clock,
						wren_a=>wren_d,wren_b=>'0',
						address_a=>add_d,address_b=>add_c,
						data_a=>data_d,data_b=>(others=>'0'),
						q_a=>q_d,q_b=>q_c);
	
	u8:sd_ram port map(clock_a=>not clk,clock_b=>CLK_sd,
						wren_a=>'0',wren_b=>wren_f,
						address_a=>add_e,address_b=>add_f,
						data_a=>(others=>'0'),data_b=>data_f,
						q_a=>q_e,q_b=>q_f);
						
	u9:wavereader port map(clk=>clk,bigclk=>bigclk,enable=>enable_wav,progress=>progress,
						finish=>finish_wav,add=>add_c_wav,q=>q_c,output=>output_wav);
			
	u10:sd_control port map(DATAOUT=>DATAOUT,CS=>CS,DATAIN=>DATAIN,CLK=>CLK_sd,
						wren=>wren_f,add_file=>add_f,data_file=>data_f,
						out_file=>q_f,clkin=>clk,reset=>reset_sd,
						ready=>ready_sd,command=>cmd_sd,SpC=>SpC);
						
	u11:file_ctrl port map(clk=>clk,command=>cmd_file,done=>done_file,SpC=>SpC,
							add_file=>add_d,data_file=>data_d,q_file=>q_d,wren_file=>wren_d,
							add_sd=>add_e,q_sd=>q_e,cmd_to_sd=>cmd_sd,ready_sd=>ready_sd);
	
	u12:console_ctrl port map(add_file=>add_c_console,q_file=>q_c,
							clk=>clk,stat_main=>stat_console,
							add_console=>add_g,data_console=>data_g,
							q_console=>q_g,wren_console=>wren_g);
	
	u13:keyboard_ctrl port map(reset=>reset,clk=>clk,KCLK=>KCLK,KDAT=>KDAT,left=>left,
							up=>up,down=>down,enter=>enter,pgup=>pgup,pgdown=>pgdown);
	
	add_c<=add_c_console when switcher=console
		else add_c_wav when switcher=wav
		else add_c_mid;
	
	output<=output_wav when switcher=wav
		else output_mid when switcher=mid
		else (others=>'0');
	
	process (clk,reset)
	begin
		if reset='1' then
			switcher<=console;
			enable_mid<='0';
			enable_wav<='0';
			stat_console<="00000";
			reset_sd<='1';
			cmd_file<="00000000";
			menu_pos<="11111";
			stat<=init;
		elsif clk'event and clk='0' then
			case stat is
				when init=>
					special<="0000";
					reset_sd<='1';
					if ready_sd='0' then
						stat<=wait_done;
					end if;
					
				when wait_done=>
					reset_sd<='0';
					if done_wm8731='1' and ready_sd='1' then
						menu_pos<="00011";
						stat<=mainmenu;
					end if;
				
				when mainmenu=>
					special<="0000";
					stat_console<="00001";
					if (up xor oldup)='1' then
						if menu_pos>3 then
							menu_pos<=menu_pos-3;
						end if;
						oldup<=up;
					elsif (down xor olddown)='1' then
						if menu_pos<12 then
							menu_pos<=menu_pos+3;
						end if;
						olddown<=down;
					elsif (left xor oldleft)='1' then
						oldleft<=left;
					elsif (enter xor oldenter)='1' then
						if menu_pos=3 then
							menu_pos<="00001";
							cmd_file<="00000010";
							stat<=wait_file;
							nstat<=select_mid;
						elsif menu_pos=6 then
							menu_pos<="00001";
							cmd_file<="00000011";
							stat<=wait_file;
							nstat<=select_wav;
						elsif menu_pos=9 then
							menu_pos<=(others=>'1');
							stat<=about;
						else
							menu_pos<=(others=>'1');
							stat<=init;
						end if;
						oldenter<=enter;
					elsif (pgup xor oldpgup)='1' then
						oldpgup<=pgup;
					elsif (pgdown xor oldpgdown)='1' then
						oldpgdown<=pgdown;
					end if;
				
				when select_mid=>
					stat_console<="00011";
					if (up xor oldup)='1' then
						if menu_pos>1 then
							menu_pos<=menu_pos-1;
						end if;
						oldup<=up;
					elsif (down xor olddown)='1' then
						if menu_pos<20 then
							menu_pos<=menu_pos+1;
						end if;
						olddown<=down;
					elsif (left xor oldleft)='1' then
						menu_pos<="00011";
						stat<=mainmenu;
						oldleft<=left;
					elsif (enter xor oldenter)='1' then
						oldenter<=enter;
					elsif (pgup xor oldpgup)='1' then
						oldpgup<=pgup;
					elsif (pgdown xor oldpgdown)='1' then
						oldpgdown<=pgdown;
					end if;
				
				when select_wav=>
					stat_console<="00011";
					if (up xor oldup)='1' then
						if menu_pos>1 then
							menu_pos<=menu_pos-1;
						end if;
						oldup<=up;
					elsif (down xor olddown)='1' then
						if menu_pos<20 then
							menu_pos<=menu_pos+1;
						end if;
						olddown<=down;
					elsif (left xor oldleft)='1' then
						menu_pos<="00110";
						stat<=mainmenu;
						oldleft<=left;
					elsif (enter xor oldenter)='1' then
						switcher<=wav;
						now_page<='0';
						cmd_file<="100"&(menu_pos-1);
						menu_pos<=(others=>'1');
						stat<=wait_file;
						nstat<=play_wav;
						oldenter<=enter;
					elsif (pgup xor oldpgup)='1' then
						oldpgup<=pgup;
					elsif (pgdown xor oldpgdown)='1' then
						oldpgdown<=pgdown;
					end if;
				
				when play_wav=>
					special<="0001";
					stat_console<="00100";
					if finish_wav='1' then
						menu_pos<="11111";
						switcher<=console;
						enable_wav<='0';
						reset_sd<='1';
						stat<=init;
					else
						enable_wav<='1';
						if add_c(7)=now_page then
							cmd_file(7 downto 1)<="0000011";
							cmd_file(0)<=not now_page;
							now_page<=not now_page;
							stat<=wait_file;
							nstat<=play_wav;
						elsif (pgup xor oldpgup)='1' then
							command_wm8731<="0001";
							stat<=wait_wm8731;
							nstat<=play_wav;
							oldpgup<=pgup;
						elsif (pgdown xor oldpgdown)='1' then
							command_wm8731<="0010";
							stat<=wait_wm8731;
							nstat<=play_wav;
							oldpgdown<=pgdown;
						end if;
					end if;
				
				when about=>
					special<="0010";
					stat_console<="00010";
					if (up xor oldup)='1' then
						oldup<=up;
					elsif (down xor olddown)='1' then
						olddown<=down;
					elsif (left xor oldleft)='1' then
						menu_pos<="01001";
						stat<=mainmenu;
						oldleft<=left;
					elsif (enter xor oldenter)='1' then
						menu_pos<="01001";
						stat<=mainmenu;
						oldenter<=enter;
					elsif (pgup xor oldpgup)='1' then
						oldpgup<=pgup;
					elsif (pgdown xor oldpgdown)='1' then
						oldpgdown<=pgdown;
					end if;
				
				when wait_file=>
					cmd_file<="00000000";
					if done_file='1' then
						stat<=nstat;
					end if;
					
				when wait_wm8731=>
					command_wm8731<="0000";
					if done_wm8731='1' then
						stat<=nstat;
					end if;
					
				when others=>
			end case;
		end if;
	end process;
	
end;