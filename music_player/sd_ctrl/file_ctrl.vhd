library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity file_ctrl is
	port (
		clk:in std_logic;
		
		command:in std_logic_vector(7 downto 0);
		done:out std_logic;
		
		add_file:buffer std_logic_vector(9 downto 0);
		data_file:out std_logic_vector(7 downto 0);
		q_file:in std_logic_vector(7 downto 0);
		wren_file:out std_logic:='0';
		
		add_sd:buffer std_logic_vector(8 downto 0);
		q_sd:in std_logic_vector(7 downto 0);
		
		cmd_to_sd:out std_logic_vector(17 downto 0):="000000000000000000";
		ready_sd:in std_logic;
		SpC:in std_logic_vector(7 downto 0)
	);
end;

architecture main of file_ctrl is

type stat_type is (idle,copy,file_check,
					fc0,fc1,fc2,fc3,fc4,
					fca,fcb,fcc,fcd,fce,fcf,
					fetch_next_dir_page,
					fetch_prev_dir_page,
					get_dir_page,clean_page,
					fetch_file_page,
					ffp1,ffp2,ffp3,ffp4,ffp5,ffp6,
					fetch_next_file_page,
					fnfp1,fnfp2,fnfp3,fnfp4,
					clean_file,wait_done);
signal stat,nstat,aftcheck,aftcopy:stat_type:=idle;

signal type_filter:std_logic;

signal prev_page:std_logic_vector(5 downto 0);
signal prev_pos:std_logic_vector(3 downto 0);
signal dir_page:std_logic_vector(5 downto 0);
signal dir_pos:std_logic_vector(3 downto 0);
signal rec_pos:std_logic_vector(4 downto 0);

signal sides:std_logic;
signal file_cluster:std_logic_vector(15 downto 0);
signal file_page:std_logic_vector(7 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if command=1 then
				stat<=idle;
			else
				case stat is
					when idle=>
						wren_file<='0';
						--fetch the first page of file
						if command(7)='1' then
							sides<='0';
							file_page<=(others=>'0');
							add_file<="0"&command(4 downto 0)&"1110";
							stat<=fetch_file_page;
							done<='0';
						--fetch the first page of root dir .msf
						elsif command=2 then
							type_filter<='0';
							stat<=clean_page;
							nstat<=fetch_next_dir_page;
							done<='0';
						--fetch the first page of root dir .wav
						elsif command=3 then
							type_filter<='1';
							stat<=clean_page;
							nstat<=fetch_next_dir_page;
							done<='0';
						--fetch next page of root dir
						elsif command=4 then
							if dir_page=32 then
								stat<=wait_done;
							else
								prev_page<=dir_page;
								prev_pos<=dir_pos;
								rec_pos<=(others=>'0');
								add_file<=(others=>'1');
								stat<=clean_file;
								nstat<=fetch_next_dir_page;
							end if;
							done<='0';
						--fetch prev page of root dir
						elsif command=5 then
							if prev_page=0 and prev_pos=0 then
								stat<=wait_done;
							else
								dir_page<=prev_page;
								dir_pos<=prev_pos;
								rec_pos<="10100";
								add_file<=(others=>'1');
								stat<=clean_file;
								nstat<=fetch_prev_dir_page;
							end if;
							done<='0';
						--fetch next page of file(1st half)
						elsif command=6 then
							sides<='0';
							file_page<=file_page+1;
							stat<=fetch_next_file_page;
							done<='0';
						--fetch next page of file(2nd half)
						elsif command=7 then
							sides<='1';
							file_page<=file_page+1;
							stat<=fetch_next_file_page;
							done<='0';
						else
							done<='1';
						end if;

					when clean_page=>
						dir_page<=(others=>'0');
						dir_pos<=(others=>'0');
						rec_pos<=(others=>'0');
						prev_page<=(others=>'0');
						prev_pos<=(others=>'0');
						add_file<=(others=>'1');
						stat<=clean_file;
				
					when fetch_file_page=>
						dir_page<=q_file(5 downto 0);
						add_file<=add_file+1;
						stat<=ffp1;
					
					when ffp1=>
						dir_pos<=q_file(3 downto 0);
						stat<=ffp2;
					
					when ffp2=>
						stat<=get_dir_page;
						nstat<=ffp3;
						
					when ffp3=>
						add_sd<=dir_pos&"11010";
						stat<=ffp4;
					
					when ffp4=>
						file_cluster(7 downto 0)<=q_sd;
						add_sd<=add_sd+1;
						stat<=ffp5;
					
					when ffp5=>
						file_cluster(15 downto 8)<=q_sd;
						stat<=ffp6;
						
					when ffp6=>
						cmd_to_sd<="01"&file_cluster;
						if ready_sd='0' then
							add_file(9)<=not sides;
							add_file(8 downto 0)<=(others=>'1');
							add_sd<=(others=>'0');
							stat<=wait_done;
							nstat<=copy;
							aftcopy<=idle;
						end if;
						
					when fetch_next_file_page=>
						if file_page=SpC then
							cmd_to_sd<="1000000000"&file_cluster(15 downto 8);
							if ready_sd='0' then
								file_page<=(others=>'0');
								stat<=wait_done;
								nstat<=fnfp2;
							end if;
						else
							stat<=fnfp1;
						end if;
					
					when fnfp1=>
						cmd_to_sd<="000000000000000001";
						if ready_sd='0' then
							add_file(9)<=not sides;
							add_file(8 downto 0)<=(others=>'1');
							add_sd<=(others=>'0');
							stat<=wait_done;
							nstat<=copy;
							aftcopy<=idle;
						end if;
					
					when fnfp2=>
						add_sd<=file_cluster(7 downto 0)&"0";
						stat<=fnfp3;
					
					when fnfp3=>
						add_sd<=add_sd+1;
						file_cluster(7 downto 0)<=q_sd;
						stat<=fnfp4;
					
					when fnfp4=>
						file_cluster(15 downto 8)<=q_sd;
						stat<=ffp6;
					
					when copy=>
						wren_file<='1';
						data_file<=q_sd;
						add_file<=add_file+1;
						add_sd<=add_sd+1;
						if add_file(8 downto 0)="111111111" and add_file(9)=sides then
							stat<=aftcopy;
						end if;
					
					when clean_file=>
						add_file<=add_file+1;
						data_file<=(others=>'0');
						if add_file="111111110" then
							wren_file<='0';
							stat<=get_dir_page;
						else
							wren_file<='1';
							stat<=clean_file;
						end if;
					
					when fetch_next_dir_page=>
						if rec_pos=20 or dir_page=32 then
							stat<=idle;
						else
							if dir_pos=15 then
								dir_page<=dir_page+1;
								stat<=get_dir_page;
								nstat<=file_check;
							else
								stat<=file_check;
							end if;
							aftcheck<=fetch_next_dir_page;
						end if;
						
					when fetch_prev_dir_page=>
						if rec_pos=0 then
							stat<=idle;
						else
							if prev_pos=0 then
								prev_page<=prev_page-1;
								stat<=get_dir_page;
								nstat<=file_check;
							else
								stat<=file_check;
							end if;
							aftcheck<=fetch_prev_dir_page;
							dir_pos<=dir_pos-1;
						end if;
					
					when file_check=>
						add_sd<=dir_pos&"00000";
						stat<=fc0;
						
					when fc0=>
						if (q_sd="00000000") or (q_sd="11100101") or
							(q_sd="00000101") or (q_sd="00101110") then
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						else
							add_sd<=dir_pos&"01000";
							if type_filter='0' then
								stat<=fca;
							else
								stat<=fcd;
							end if;
						end if;
					
					when fca=>
						if (q_sd="01001101") or (q_sd="01101101") then
							add_sd<=dir_pos&"01001";
							stat<=fcb;
						else
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						end if;
					
					when fcb=>
						if (q_sd="01010011") or (q_sd="01110011") then
							add_sd<=dir_pos&"01010";
							stat<=fcc;
						else
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						end if;
					
					when fcc=>
						if (q_sd="01000110") or (q_sd="01100110") then
							add_sd<=dir_pos&"01011";
							stat<=fc1;
						else
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						end if;
					
					when fcd=>
						if (q_sd="01010111") or (q_sd="01110111") then
							add_sd<=dir_pos&"01001";
							stat<=fce;
						else
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						end if;
					
					when fce=>
						if (q_sd="01000001") or (q_sd="01100001") then
							add_sd<=dir_pos&"01010";
							stat<=fcf;
						else
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						end if;
					
					when fcf=>
						if (q_sd="01010110") or (q_sd="01110110") then
							add_sd<=dir_pos&"01011";
							stat<=fc1;
						else
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						end if;
									
					when fc1=>
						if (q_sd(7 downto 6)&q_sd(4 downto 3))=0 then
							add_sd<=dir_pos&"00000";
							add_file<=("0"&rec_pos&"0000")-1;
							rec_pos<=rec_pos+1;
							stat<=fc2;
						else
							dir_pos<=dir_pos+1;
							stat<=aftcheck;
						end if;
					
					when fc2=>
						wren_file<='1';
						if add_sd(4 downto 0)="01011" then
							data_file<="00"&dir_page;
							add_file<=add_file+4;
							stat<=fc3;
						else
							data_file<=q_sd;
							add_file<=add_file+1;
							add_sd<=add_sd+1;
						end if;
					
					when fc3=>
						data_file<="0000"&dir_pos;
						add_file<=add_file+1;
						stat<=fc4;
						
					when fc4=>
						wren_file<='0';
						dir_pos<=dir_pos+1;
						stat<=aftcheck;
					
					when get_dir_page=>
						cmd_to_sd<="001000000000"&dir_page;
						if ready_sd='0' then
							stat<=wait_done;
						end if;
						
					when wait_done=>
						cmd_to_sd<=(others=>'0');
						if ready_sd='1' then
							stat<=nstat;
						end if;
				end case;
			end if;
		end if;
	end process;
		
end;