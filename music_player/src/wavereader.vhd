library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity wavereader is
	port (
		clk,bigclk,enable:in std_logic;
		finish:out std_logic;
		add:buffer std_logic_vector(7 downto 0);
		q:in std_logic_vector(31 downto 0);
		
		progress:buffer std_logic_vector(7 downto 0);
		output:out std_logic_vector(15 downto 0)
	);
end;

architecture main of wavereader is

type stat_type is (read_header,
					find_fmt,ff1,ff2,ff3,
					find_data,fd1,fd2,fd3,
					find_next_chunk,fnc1,
					calc_end,ce1,ce2,ce3,ce4,
					check_fmt,cf1,cf2,cf3,
					check_rate,cr1,cr2,cr3,
					check_bps,
					playing,
					read_signal,rs1,
					finishs);
signal stat,nstat,aftfnc:stat_type:=finishs;

signal tip,tap:std_logic;
signal sepq:std_logic_vector(7 downto 0);
signal chunk_end,sepadd,start:std_logic_vector(31 downto 0):=(others=>'0');

signal output_left,output_right:std_logic_vector(15 downto 0):=(others=>'0');

signal temp0:std_logic_vector(31 downto 0);
signal temp1:std_logic_vector(31 downto 0);
signal temp2:std_logic_vector(32 downto 0);
signal temp3:std_logic_vector(33 downto 0);
signal temp4:std_logic_vector(34 downto 0);
signal temp5:std_logic_vector(35 downto 0);
signal temp6:std_logic_vector(36 downto 0);
signal temp7:std_logic_vector(37 downto 0);

begin

	temp0<=chunk_end-start;
	
	progress(7)<='1' when
		((sepadd-start)&"0">temp0) else '0';
		
	temp1<=temp0 when progress(7)='1' else (others=>'0');
	
	progress(6)<='1' when
		(((sepadd-start)&"00")-(temp1&"0")>temp0) else '0';
		
	temp2<=temp0+(temp1&"0") when progress(6)='1' else (temp1&"0");
	
	progress(5)<='1' when
		((sepadd-start)&"000"-(temp2&"0")>temp0) else '0';
		
	temp3<=temp0+(temp2&"0") when progress(5)='1' else (temp2&"0");
	
	progress(4)<='1' when
		((sepadd-start)&"0000"-(temp3&"0")>temp0) else '0';
	
	temp4<=temp0+(temp3&"0") when progress(4)='1' else (temp3&"0");
	
	progress(3)<='1' when
		((sepadd-start)&"00000"-(temp4&"0")>temp0) else '0';
		
	temp5<=temp0+(temp4&"0") when progress(3)='1' else (temp4&"0");
		
	progress(2)<='1' when
		((sepadd-start)&"000000"-(temp5&"0")>temp0) else '0';
	
	temp6<=temp0+(temp5&"0") when progress(2)='1' else (temp5&"0");
	
	progress(1)<='1' when
		((sepadd-start)&"0000000"-(temp6&"0")>temp0) else '0';
		
	temp7<=temp0+(temp6&"0") when progress(1)='1' else (temp6&"0");
	
	progress(0)<='1' when
		((sepadd-start)&"00000000"-(temp7&"0")>temp0) else '0';

	process(bigclk)
	begin
		if bigclk'event and bigclk='1' then
			if stat=playing then
				tap<=not tip;
			end if;
		end if;
	end process;

	process(clk,enable)
	begin
		if enable='0' then
			finish<='0';
			stat<=read_header;
		elsif clk'event and clk='1' then
			case stat is
				when read_header=>
					sepadd<="00000000000000000000000000001100";
					stat<=find_fmt;
				
				when find_fmt=>
					if sepq="01100110" then
						sepadd<=sepadd+1;
						stat<=ff1;
					else
						sepadd<=sepadd+4;
						nstat<=find_fmt;
						stat<=find_next_chunk;
					end if;
				
				when ff1=>
					if sepq="01101101" then
						sepadd<=sepadd+1;
						stat<=ff2;
					else
						sepadd<=sepadd+3;
						nstat<=find_fmt;
						stat<=find_next_chunk;
					end if;
				
				when ff2=>
					if sepq="01110100" then
						sepadd<=sepadd+1;
						stat<=ff3;
					else
						sepadd<=sepadd+2;
						nstat<=find_fmt;
						stat<=find_next_chunk;
					end if;
				
				when ff3=>
					sepadd<=sepadd+1;
					if sepq="00100000" then
						nstat<=check_fmt;
						stat<=calc_end;
					else
						nstat<=find_fmt;
						stat<=find_next_chunk;
					end if;
				
				when find_next_chunk=>
					aftfnc<=nstat;
					nstat<=fnc1;
					stat<=calc_end;
				
				when fnc1=>
					sepadd<=chunk_end;
					stat<=aftfnc;
				
				when calc_end=>
					chunk_end(7 downto 0)<=sepq;
					sepadd<=sepadd+1;
					stat<=ce1;
				
				when ce1=>
					chunk_end(15 downto 8)<=sepq;
					sepadd<=sepadd+1;
					stat<=ce2;
				
				when ce2=>
					chunk_end(23 downto 16)<=sepq;
					sepadd<=sepadd+1;
					stat<=ce3;
				
				when ce3=>
					chunk_end(31 downto 24)<=sepq;
					sepadd<=sepadd+1;
					stat<=ce4;
				
				when ce4=>
					chunk_end<=chunk_end+sepadd;
					stat<=nstat;
				
				when check_fmt=>
					if sepq=1 then
						sepadd<=sepadd+1;
						stat<=cf1;
					else
						stat<=finishs;
					end if;
					
				when cf1=>
					if sepq=0 then
						sepadd<=sepadd+1;
						stat<=cf2;
					else
						stat<=finishs;
					end if;
					
				when cf2=>
					if sepq=2 then
						sepadd<=sepadd+1;
						stat<=cf3;
					else
						stat<=finishs;
					end if;
					
				when cf3=>
					if sepq=0 then
						sepadd<=sepadd+1;
						stat<=check_rate;
					else
						stat<=finishs;
					end if;
					
				when check_rate=>
					if sepq=128 then
						sepadd<=sepadd+1;
						stat<=cr1;
					else
						stat<=finishs;
					end if;
				
				when cr1=>
					if sepq=187 then
						sepadd<=sepadd+1;
						stat<=cr2;
					else
						stat<=finishs;
					end if;
				
				when cr2=>
					if sepq=0 then
						sepadd<=sepadd+1;
						stat<=cr3;
					else
						stat<=finishs;
					end if;
				
				when cr3=>
					if sepq=0 then
						sepadd<=sepadd+7;
						stat<=check_bps;
					else
						stat<=finishs;
					end if;
				
				when check_bps=>
					if sepq=8 then
						sepadd<=chunk_end;
						stat<=find_data;
					else
						stat<=finishs;
					end if;
				
				when find_data=>
					if sepq="01100100" then
						sepadd<=sepadd+1;
						stat<=fd1;
					else
						sepadd<=sepadd+4;
						nstat<=find_data;
						stat<=find_next_chunk;
					end if;
				
				when fd1=>
					if sepq="01100001" then
						sepadd<=sepadd+1;
						stat<=fd2;
					else
						sepadd<=sepadd+3;
						nstat<=find_data;
						stat<=find_next_chunk;
					end if;
				
				when fd2=>
					if sepq="01110100" then
						sepadd<=sepadd+1;
						stat<=fd3;
					else
						sepadd<=sepadd+2;
						nstat<=find_data;
						stat<=find_next_chunk;
					end if;
				
				when fd3=>
					sepadd<=sepadd+1;
					if sepq="01100001" then
						start<=sepadd;
						nstat<=playing;
						stat<=calc_end;
					else
						nstat<=find_data;
						stat<=find_next_chunk;
					end if;
				
				when playing=>
					if (tip xor tap)='1' then
						if sepadd>=chunk_end then
							stat<=finishs;
						else
							sepadd<=sepadd+1;
							stat<=read_signal;
						end if;
						tip<=tap;
					end if;
				
				when read_signal=>
					output_left(14 downto 7)<=sepq;
					sepadd<=sepadd+1;
					stat<=rs1;
				
				when rs1=>
					output_right(14 downto 7)<=sepq;
					stat<=playing;
				
				when finishs=>
					finish<='1';
			end case;
		end if;
	end process;

	add<=sepadd(9 downto 2);

	sepq<=q(31 downto 24) when sepadd(1 downto 0)="11"
		else q(23 downto 16) when sepadd(1 downto 0)="10"
		else q(15 downto 8) when sepadd(1 downto 0)="01"
		else q(7 downto 0);

	output<=output_left when bigclk='0'
		else output_right when bigclk='1';

end;