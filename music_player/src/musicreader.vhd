library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity musicreader is
	port (
		clk,bigclk,reset,enable:in std_logic;
		
		add_file:buffer std_logic_vector(7 downto 0);
		out_file:in std_logic_vector(31 downto 0);
		
		tout:out std_logic_vector(31 downto 0);
		
		add_note:buffer std_logic_vector(6 downto 0);
		data_note:out std_logic_vector(31 downto 0);
		out_note:in std_logic_vector(31 downto 0);
		wren_note:out std_logic:='0'
	);
end;

architecture main of musicreader is

type stat_type is (idle,check,proc,insert,delete,read0,read1,read2,
					update0,update1,update2,update3);

signal sf,nsf:std_logic;
signal stat:stat_type:=idle;

signal command:std_logic_vector(95 downto 0):=(others=>'0');

signal times:std_logic_vector(31 downto 0):=(others=>'0');

begin

	process (bigclk,reset)
	begin
		if bigclk'event and bigclk='0' then
			sf<=not nsf;
		end if;
	end process;
	
	process (clk,reset,enable)
	variable rnum:integer range 0 to 31;
	begin
		if reset='1' then
			times<=(others=>'0');
			add_file<=(others=>'0');
			command<=(others=>'0');
			wren_note<='0';stat<=idle;
		elsif enable='0' then
			add_note<=add_note+1;
			data_note<=(others=>'0');
			wren_note<='0';
			stat<=idle;
		elsif clk'event and clk='1' then
			nsf<=sf;
			if sf=nsf then
				case stat is
					when check=>
						if command(95 downto 64)=0 then
							stat<=read0;
						elsif command(63 downto 32)<=times then
							stat<=proc;
						else
							stat<=idle;
						end if;
						
					when proc=>
						add_note<=(others=>'0');
						if command(0)='1' then
							stat<=insert;
						else
							stat<=delete;
						end if;
						
					when insert=>
						if out_note=0 then
							wren_note<='1';
							data_note<=command(95 downto 64);
							stat<=update0;
						else
							add_note<=add_note+4;
						end if;
					
					when delete=>
						if out_note=command(95 downto 64) then
							wren_note<='1';
							data_note<=(others=>'0');
							stat<=update0;
						else
							add_note<=add_note+4;
						end if;
					
					when update0=>
						if command(0)='1' then
							data_note<="0000000000000000"&command(31 downto 16);
						else
							data_note<=(others=>'0');
						end if;
						add_note<=add_note+1;
						stat<=update1;
					
					when update1=>
						if command(0)='1' then
							data_note<=command(15 downto 8)&"000000000000000000000000";
						else
							data_note<=(others=>'0');
						end if;
						add_note<=add_note+1;
						stat<=update2;
					
					when update2=>
						data_note<=(others=>'0');
						add_note<=add_note+1;
						stat<=update3;
					
					when update3=>
						wren_note<='0';
						add_note<=add_note+1;
						stat<=read0;
					
					when read0=>						
						command(95 downto 64)<=out_file;
						add_file<=add_file+1;
						stat<=read1;
					
					when read1=>
						command(63 downto 32)<=out_file;
						add_file<=add_file+1;
						stat<=read2;
					
					when read2=>
						command(31 downto 0)<=out_file;
						add_file<=add_file+1;
						stat<=check;
					
					when idle=>
				end case;
			else
				times<=times+1;
				stat<=check;
			end if;
		end if;
	end process;
	
	tout(23 downto 0)<=times(23 downto 0);
	tout(30 downto 24)<=add_file(6 downto 0);
	tout(31)<='1' when stat=delete else '0';
	
end;
