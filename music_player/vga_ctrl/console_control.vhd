library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity console_ctrl is
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
end;

architecture main of console_ctrl is

	COMPONENT text_rom IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	type stat_type is (redraw,idle,clean,draw,put_title,
						dir1,dir2,dir3,dir4,
						about1,about2,about3,about4,about5,about6,
						mmn1,mmn2,mmn3,mmn4);
	signal stat:stat_type:=redraw;
	
	signal flash,oldflh:std_logic;
	signal old_stat:std_logic_vector(4 downto 0);
	signal add_text:std_logic_vector(9 downto 0);
	signal q_text:std_logic_vector(7 downto 0);
	
begin
	
	u1:text_rom port map(address=>add_text,clock=>not clk,q=>q_text);
	
	process(stat_main,old_stat)
	begin
		if not (stat_main=old_stat) then
			flash<=not oldflh;
			old_stat<=stat_main;
		end if;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if (flash xor oldflh)='1' then
				oldflh<=flash;
				stat<=redraw;
			else
				case stat is
					when redraw=>
						add_console<=(others=>'0');
						data_console<=(others=>'0');
						wren_console<='1';
						stat<=clean;
						
					when clean=>
						if add_console="11111111111" then
							wren_console<='0';
							add_text<=(others=>'0');
							stat<=put_title;
						else
							add_console<=add_console+1;
						end if;
					
					when put_title=>
						wren_console<='1';
						add_console<=add_console+1;
						data_console<=q_text;
						
						add_text<=add_text+1;
						if add_text=23 then
							stat<=draw;
						end if;
					
					when draw=>
						wren_console<='0';
						if stat_main=1 then
							add_text<="0000011000";
							add_console<="00100000011";
							stat<=mmn1;
						elsif stat_main=2 then
							add_text<="0001100110";
							add_console<="00100000011";
							stat<=about1;
						elsif stat_main=3 then
							add_file<=(others=>'0');
							add_console<="00010000011";
							stat<=dir1;
						else
							stat<=idle;
						end if;
					
					when dir1=>
						wren_console<='1';
						add_console<=add_console+1;
						data_console<=q_file(7 downto 0);
						stat<=dir2;
					
					when dir2=>
						wren_console<='1';
						add_console<=add_console+1;
						data_console<=q_file(15 downto 8);
						stat<=dir3;
					
					when dir3=>
						wren_console<='1';
						add_console<=add_console+1;
						data_console<=q_file(23 downto 16);
						stat<=dir4;
					
					when dir4=>
						wren_console<='1';
						data_console<=q_file(31 downto 24);
						if not (add_file(1 downto 0)="10") then
							add_console<=add_console+1;
							add_file<=add_file+1;
							stat<=dir1;
						elsif add_file(7 downto 2)=19 then
							stat<=idle;
						else
							add_file<=add_file+2;
							add_console<=add_console+"00000110101";
							stat<=dir1;
						end if;
					
					when about1=>
						wren_console<='1';
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=125 then
							add_console<="00110000100";
							stat<=about2;
						else
							add_console<=add_console+1;
						end if;
					
					when about2=>
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=139 then
							add_console<="01010000100";
							stat<=about3;
						else
							add_console<=add_console+1;
						end if;
						
					when about3=>
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=192 then
							add_console<="01100000100";
							stat<=about4;
						else
							add_console<=add_console+1;
						end if;

					when about4=>
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=243 then
							add_console<="01110000100";
							stat<=about5;
						else
							add_console<=add_console+1;
						end if;

					when about5=>
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=292 then
							add_console<="10000000100";
							stat<=about6;
						else
							add_console<=add_console+1;
						end if;

					when about6=>
						data_console<=q_text;
						add_console<=add_console+1;
						
						add_text<=add_text+1;
						if add_text=325 then
							stat<=idle;
						end if;
						
					when mmn1=>
						wren_console<='1';
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=48 then
							add_console<="00111000100";
							stat<=mmn2;
						else
							add_console<=add_console+1;
						end if;
					
					when mmn2=>
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=64 then
							add_console<="01010000100";
							stat<=mmn3;
						else
							add_console<=add_console+1;
						end if;
					
					when mmn3=>
						data_console<=q_text;
						add_text<=add_text+1;
						if add_text=90 then
							add_console<="01101000100";
							stat<=mmn4;
						else
							add_console<=add_console+1;
						end if;
					
					when mmn4=>
						data_console<=q_text;
						add_console<=add_console+1;
						
						add_text<=add_text+1;
						if add_text=101 then
							stat<=idle;
						end if;
					
					when idle=>
						wren_console<='0';
				end case;
			end if;
		end if;
	end process;
	
end;