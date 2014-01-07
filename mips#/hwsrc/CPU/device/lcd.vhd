library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lcd is
	port(
		clk_lcd:in std_logic;
		
		sram_addr:buffer std_logic_vector(17 downto 0);
		sram_data:in std_logic_vector(15 downto 0);
		
		txt_addr:buffer std_logic_vector(9 downto 0);
		txt_data:in std_logic_vector(15 downto 0);
		
		hd,vd,clk_lcd_out,rst,cpw:out std_logic;
		dout:out std_logic_vector(7 downto 0)
	);
end;

architecture main of lcd is

	component asc16_rom IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	end component;

signal i:integer range 7 downto 0;

signal en,en_x,en_y:std_logic;
signal x,y:std_logic_vector(10 downto 0);
signal color:std_logic_vector(1 downto 0);
signal counter:std_logic_vector(0 downto 0);
signal txt_row:std_logic_vector(3 downto 0);
signal txt_pos:std_logic_vector(9 downto 0);
signal pixel,nout:std_logic_vector(7 downto 0);
signal backcolor,forecolor,imagecolor:std_logic_vector(7 downto 0);
signal rbc,gbc,bbc,rfc,gfc,bfc:std_logic_vector(7 downto 0);

signal curX,nowX,startX:std_logic_vector(3 downto 0);
signal curY,nowY:std_logic_vector(5 downto 0);

signal wink:std_logic;
signal wink_count:std_logic_vector(23 downto 0);

begin
	
	process(clk_lcd)
	begin
		if clk_lcd'event and clk_lcd='0' then
			wink_count<=wink_count+1;
			if wink_count="0" then
				wink<=not wink;
			end if;
		end if;
	end process;
	
	process(clk_lcd)
	begin
		if clk_lcd'event and clk_lcd='0' then
			if x=1170 then
				x<=(others=>'0');
				if y=262 then
					y<=(others=>'0');
				else
					y<=y+1;
				end if;
			else
				x<=x+1;
			end if;
		end if;
	end process;
	
	clk_lcd_out<=clk_lcd;
	hd<='0' when x=0 else '1';
	vd<='0' when y=0 else '1';
	rst<='1';
	cpw<='1';
	
	nout<=(others=>'0')	when en='0' else
		  forecolor		when pixel(i)='1' else		--font pixel
		  backcolor		when txt_data(14)='1' else	--not transparent
		  imagecolor;
	
	dout<=not nout when nowX=curX and nowY=curY 
					and wink='1' else nout;
	
	backcolor<=rbc when color="00" else
				gbc when color="01" else
				bbc;
	
	forecolor<=rfc when color="00" else
				gfc when color="01" else
				bfc;

	imagecolor<=sram_data(7 downto 0) when color(0)='0' else
				sram_data(15 downto 8);
	
	rbc<="01100000" when txt_data(11)='1' else "00000000";
	gbc<="01100000" when txt_data(12)='1' else "00000000";
	bbc<="01100000" when txt_data(13)='1' else "00000000";
	rfc<="01100000" when txt_data(8)='0' else "00000000";
	gfc<="01100000" when txt_data(9)='0' else "00000000";
	bfc<="01100000" when txt_data(10)='0' else "00000000";
	
	en_x<='1' when x>=152 and x<1112 else '0';
	en_y<='1' when y>=14 and y<254 else '0';
	en<=en_x and en_y;
	
	process(clk_lcd)
	begin
		if clk_lcd'event and clk_lcd='0' then
			if en='0' then
				color<="00";
			else
				case color is
				when "00"=>
					color<="01";
				when "01"=>
					color<="10";
				when "10"=>
					color<="00";
				when "11"=>
					color<="00";
				end case;
			end if;
		end if;
	end process;

	process(clk_lcd)
	begin
		if clk_lcd'event and clk_lcd='0' then
			if y=1 then
				sram_addr<=(others=>'0');
			elsif en='1' then
				if not (color="00") then
					sram_addr<=sram_addr+1;
				end if;
			end if;
		end if;
	end process;
	
	process(clk_lcd)
	begin
		if clk_lcd'event and clk_lcd='0' then
			if en_y='0' then
				nowX<="1111";
				nowY<="000000";
				txt_pos<=("000"&startX&"000")+("0"&startX&"00000");
			elsif en_x='1' then
				
				if color="00" and i=0 then
					txt_pos<=txt_pos+1;
					nowY<=nowY+1;
				end if;
				
				if color="10" then
					if i=0 then
						i<=7;
					else
						i<=i-1;
					end if;
				end if;
				
			elsif x=1 then
				if y(3 downto 0)="1110" then
					nowX<=nowX+1;
				else
					txt_pos<=txt_pos-40;
				end if;
				nowY<="000000";
			end if;
		end if;
	end process;
	txt_row<=y(3 downto 0)-"1110";
	
	process(clk_lcd)
	begin
		if clk_lcd'event and clk_lcd='0' then
			if y=0 and x=2 then
				curX<=txt_data(3 downto 0);
				curY<=txt_data(9 downto 4);
				startX<=txt_data(13 downto 10);
			end if;
		end if;
	end process;
	
	txt_addr<="1001011000"	when y=0 else
			txt_pos			when txt_pos<600 else
			txt_pos-600;
	
	u0:asc16_rom port map(clock=>clk_lcd,address=>txt_data(7 downto 0)&txt_row,q=>pixel);
	
end;