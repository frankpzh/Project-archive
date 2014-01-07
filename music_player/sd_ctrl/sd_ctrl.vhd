library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sd_control is
	port(
		DATAOUT:in std_logic;
		CS,DATAIN:out std_logic;
		CLK:out std_logic;
		
		ready:out std_logic;
		command:in std_logic_vector(17 downto 0);
		SpC:buffer std_logic_vector(7 downto 0);
		
		wren:out std_logic;
		add_file:buffer std_logic_vector(8 downto 0);
		data_file:out std_logic_vector(7 downto 0);
		out_file:in std_logic_vector(7 downto 0);

		clkin,reset:in std_logic
	);
end;

architecture main of sd_control is

type stat_type is (not_in,GO_IDLE_STATE,SEND_OP_COND,CHECK_OP_COND,
					SET_BLOCKLEN,READ_SINGLE_BLOCK,wait_data,read_data,
					send_com,receive_r1,receive_r1b,receive_r2,
					fetch_syspos,fetch_dirpos,fetch_root,wait_command);
type response_type is (r1,r1b,r2);

signal stat:stat_type:=not_in;
signal nstat,aftread:stat_type;
signal rtype:response_type;

signal res:std_logic_vector(7 downto 0);
signal cmd:std_logic_vector(47 downto 0);

signal addr,fat_addr,root_addr,data_addr:std_logic_vector(23 downto 0);

signal buf:std_logic_vector(23 downto 0);

constant fac1:std_logic_vector(13 downto 0):="11111100000000";
constant fac2:std_logic_vector(5 downto 0):="111111";

begin
	
	CLK<=not clkin;
	
	process(clkin)
	variable i:integer range 0 to 47;
	variable read_count:integer range 0 to 520;
	begin
		if clkin'event and clkin='1' then
			if reset='1' then
				ready<='0';
				stat<=not_in;
			else
				case stat is
					when not_in=>
						DATAIN<='1';CS<='1';
						add_file<=(others=>'0');
						stat<=GO_IDLE_STATE;
						
					when GO_IDLE_STATE=>
						i:=47;rtype<=r1;
						cmd<="01000000"&"00000000"&"00000000"&
							"00000000"&"00000000"&"10010101";
						nstat<=SEND_OP_COND;
						stat<=send_com;
					
					when SEND_OP_COND=>
						i:=47;
						rtype<=r1;
						cmd<="01000001"&"00000000"&"00000000"&
							"00000000"&"00000000"&"00000001";
						nstat<=CHECK_OP_COND;
						stat<=send_com;
					
					when CHECK_OP_COND=>
						if res(0)='0' then
							stat<=SET_BLOCKLEN;
						else
							stat<=SEND_OP_COND;
						end if;
					
					when SET_BLOCKLEN=>
						i:=47;
						rtype<=r1;
						cmd<="01010000"&"00000000"&"00000000"&
							"00000010"&"00000000"&"00000001";
						stat<=fetch_syspos;
					
					when fetch_syspos=>
						addr<="00000000"&"00000000"&"00000000";
						aftread<=fetch_dirpos;
						stat<=READ_SINGLE_BLOCK;
					
					when fetch_dirpos=>
						if add_file=447 then
							buf(7 downto 0)<=out_file;
							add_file<="111000000";
						elsif add_file=448 then
							buf(15 downto 8)<=out_file;
							add_file<="111000001";
						elsif add_file=449 then
							add_file<=(others=>'0');
							addr<=(buf(15 downto 14)&out_file)*fac1+buf(7 downto 0)*fac2+buf(13 downto 8)-1;
							aftread<=fetch_root;
							stat<=READ_SINGLE_BLOCK;
						else
							add_file<="110111111";
						end if;
					
					when fetch_root=>
						if add_file=13 then
							SpC<=out_file;
							add_file<="000010110";
						elsif add_file=22 then
							buf(7 downto 0)<=out_file;
							add_file<="000010111";
						elsif add_file=23 then
							add_file<=(others=>'0');
							fat_addr<=addr+2;
							root_addr<=addr+(out_file&buf(7 downto 0))+(out_file&buf(7 downto 0))+2;
							data_addr<=addr+(out_file&buf(7 downto 0))+(out_file&buf(7 downto 0))+34;
							stat<=wait_command;
						else
							add_file<="000001101";
						end if;
					
					when READ_SINGLE_BLOCK=>
						i:=47;
						rtype<=r1;
						cmd<="01010001"&addr(22 downto 0)&"000000000"&"00000001";
						nstat<=wait_data;
						stat<=send_com;
					
					when wait_data=>
						add_file<=(others=>'1');
						if DATAOUT='0' then
							i:=7;read_count:=0;
							stat<=read_data;
						end if;
					
					when read_data=>
						if i=0 then
							i:=7;
							if read_count<512 then
								wren<='1';
								data_file<=res(7 downto 1)&DATAOUT;
								add_file<=add_file+1;
							end if;
							if read_count=514 then					
								stat<=aftread;
							end if;
							read_count:=read_count+1;
						else
							wren<='0';
							res(i)<=DATAOUT;
							i:=i-1;
						end if;
					
					when send_com=>
						CS<='0';
						DATAIN<=cmd(i);
						if i=0 then
							i:=7;
							case rtype is
								when r1=>
									stat<=receive_r1;
								when r1b=>
									stat<=receive_r1b;
								when r2=>
									stat<=receive_r2;
							end case;
						else
							i:=i-1;
						end if;
					
					when receive_r1=>
						if i<8 then
							res(i)<=DATAOUT;
						elsif i=40 then
							stat<=nstat;
						end if;
						
						if not (i=7 and DATAOUT='1') then
							i:=i-1;
						end if;
					
					when wait_command=>
						if command(17)='1' then
							addr<=fat_addr+command(7 downto 0);
							aftread<=wait_command;
							stat<=READ_SINGLE_BLOCK;
							ready<='0';
						elsif command(16)='1' then
							addr<=data_addr+(command(15 downto 0)-2)*SpC;
							aftread<=wait_command;
							stat<=READ_SINGLE_BLOCK;
							ready<='0';
						elsif command(15)='1' then
							addr<=root_addr+command(14 downto 0);
							aftread<=wait_command;
							stat<=READ_SINGLE_BLOCK;
							ready<='0';
						elsif command=1 then
							addr<=addr+1;
							aftread<=wait_command;
							stat<=READ_SINGLE_BLOCK;
							ready<='0';
						else
							ready<='1';
						end if;
					
					when others=>
				end case;
			end if;
		end if;
	end process;
end;
