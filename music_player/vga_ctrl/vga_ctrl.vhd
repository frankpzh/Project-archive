library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga_ctrl is
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
end;

architecture main of vga_ctrl is

	COMPONENT vga_65MHz IS
		PORT
		(
			inclk0	: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC 
		);
	END COMPONENT;
	
	COMPONENT asc16_rom IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
signal HPOS,VPOS:std_logic;
signal H_count,V_count:std_logic_vector(10 downto 0);

signal r,g,b:std_logic_vector(7 downto 0);
signal X,Y:std_logic_vector(9 downto 0);

signal add_font:std_logic_vector(11 downto 0);
signal out_font:std_logic_vector(7 downto 0);

signal cx:std_logic_vector(5 downto 0);
signal cyj:std_logic_vector(8 downto 0);

signal now_pos:std_logic_vector(4 downto 0);

begin
	
	u1:vga_65MHz port map(inclk0=>clk,c0=>clk_vga);
	
	u2:asc16_rom port map(address=>add_font,q=>out_font,clock=>not clk_vga);
	
	process(clk_vga)
	begin
		if clk_vga'event and clk_vga='1' then
			if H_count=1319 then
				H_count<=(others=>'0');
			else
				H_count<=H_count+1;
			end if;
		end if;
	end process;
	
	process(clk_vga)
	begin
		if clk_vga'event and clk_vga='1' then
			if H_count=0 then
				if V_count=811 then
					V_count<=(others=>'0');
				else
					V_count<=V_count+1;
				end if;
			end if;
		end if;
	end process;
	
	HS<='1' when H_count>25 and H_count<1300 else '0';
	VS<='1' when V_count>5 and V_count<800 else '0';
	HPOS<='1' when H_count>242 and H_count<1267 else '0';
	VPOS<='1' when V_count>30 and V_count<799 else '0';
	
	SYNC<='1';
	BLANK<='1' when HS='1' and VS='1' else '0';
	RPr<=r when HPOS='1' and VPOS='1' else (others=>'0');
	GY<=g when HPOS='1' and VPOS='1' else (others=>'0');
	BPb<=b when HPOS='1' and VPOS='1' else (others=>'0');
	
	X<=H_count(9 downto 0)-243 when HPOS='1' else (others=>'0');
	Y<=V_count(9 downto 0)-31 when VPOS='1' else (others=>'0');
	
	process(clk_vga)
	variable i:integer range 0 to 7;
	begin
		if clk_vga'event and clk_vga='1' then
			if VPOS='0' then
				cyj<=(others=>'0');
				now_pos<=(others=>'1');
			elsif HPOS='0' then
				cx<=(others=>'0');
				if H_count=1270 and ((Y>=222 and Y<574)or(Y>=191 and Y<207)) then
					if cyj(3 downto 0)="1111" then
						-- 0	=>	title
						-- 1~22	=>	menu
						now_pos<=now_pos+1;
					end if;
					cyj<=cyj+1;
				end if;
			else
				if X>=262 and X<762 and Y>=184 and Y<584 then
					
					if special="0001" and X>=384 and X<640 and Y>=494 and Y<524 then
						if X-384>progress then
							r<="01111011";
							g<="10001010";
							b<="10110011";
						else
							r<="00010100";
							g<="01101011";
							b<="11111100";
						end if;
					else
						if X>=270 and X<750 and X(2 downto 0)="110" then
							add_console<=cyj(8 downto 4)&cx;
							cx<=cx+1;
						elsif X>=271 and X<751 and X(2 downto 0)="111" then
							add_font<=out_console&cyj(3 downto 0);
							i:=0;
						end if;
						
						if X>=264 and X<760 and Y>=214 and Y<582 then
							if X>=272 and X<752 and Y>=222 and Y<574 and out_font(i)='1' then
								--Font Color
								r<="00000000";
								g<="00000000";
								b<="00000000";
							else
								--Shadow Color
								if now_pos=menu_pos then
									r<="10000000";
									g<="10000000";
									b<="11111111";
								else
									r<="11101110";
									g<="11101111";
									b<="11001111";
								end if;
							end if;
						else
							if X>=272 and X<752 and Y>=191 and Y<207 and out_font(i)='1' then
								--Title Font Color
								r<="11110001";
								g<="11111011";
								b<="01111011";
							else
								--Title Shadow Color
								r<="01010111";
								g<="10001100";
								b<="11100011";
							end if;
						end if;
							
						i:=i-1;
					end if;
					
				else
					r<=(others=>'1');
					g<=(others=>'1');
					b<=(others=>'1');
				end if;
			end if;
		end if;
	end process;
end;