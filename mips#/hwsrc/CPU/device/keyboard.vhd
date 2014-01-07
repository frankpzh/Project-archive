library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;   

entity keyboard is
  port(
		sys_clock:in std_logic;
		reset:in std_logic;
       
	--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
	   
	--Interrupt
		intr:out std_logic;
       
    --Keyboard
		key_clock:in std_logic;
		key_data:in std_logic;
		ascii:buffer std_logic_vector(7 downto 0)
);
end;

architecture rtl of keyboard is
type fifo is array (0 to 7) of std_logic_vector(7 downto 0);
signal buf:fifo;

type stat_type is (normal, break, special, special_break);
signal stat:stat_type:=normal;

signal key_c:std_logic;
signal counter:integer range 0 to 10:=0;
signal rec_bitvector:std_logic_vector(10 downto 0):=(others=>'0');

signal wap,rap:std_logic_vector(2 downto 0);

signal BUS_cs,isKey:std_logic;
signal fifo_out:std_logic_vector(15 downto 0);

begin

	process(sys_clock)
	begin
		if sys_clock'event and sys_clock='1' then
			key_c<=key_clock;
		end if;
	end process;

	process(reset,key_c)
	begin
		if (reset='0') then
			counter<=0;
		elsif key_c'event and key_c='0' then
			if counter=10 then
				counter<=0;
			else
				counter<=counter+1;
			end if;
		end if;
	end process;

	process(key_c)
	begin
		if key_c'event and key_c='0' then
			rec_bitvector(counter)<=key_data;
		end if;
	end process;
	
	process(reset,key_c)
	begin
		if reset='0' then
			wap<="000";
			stat<=normal;
		elsif key_c'event and key_c='0' then
			if counter=10 then
				case stat is
				when normal=>
					wap<=wap+1;
					case rec_bitvector(8 downto 1) is
					when "01000101"=>buf(conv_integer(wap))<="00110000";--0
					when "00010110"=>buf(conv_integer(wap))<="00110001";
					when "00011110"=>buf(conv_integer(wap))<="00110010";
					when "00100110"=>buf(conv_integer(wap))<="00110011";
					when "00100101"=>buf(conv_integer(wap))<="00110100";
					when "00101110"=>buf(conv_integer(wap))<="00110101";
					when "00110110"=>buf(conv_integer(wap))<="00110110";
					when "00111101"=>buf(conv_integer(wap))<="00110111";
					when "00111110"=>buf(conv_integer(wap))<="00111000";
					when "01000110"=>buf(conv_integer(wap))<="00111001";--9
					when "00011100"=>buf(conv_integer(wap))<="01000001";--A
					when "00110010"=>buf(conv_integer(wap))<="01000010";
					when "00100001"=>buf(conv_integer(wap))<="01000011";
					when "00100011"=>buf(conv_integer(wap))<="01000100";
					when "00100100"=>buf(conv_integer(wap))<="01000101";
					when "00101011"=>buf(conv_integer(wap))<="01000110";
					when "00110100"=>buf(conv_integer(wap))<="01000111";
					when "00110011"=>buf(conv_integer(wap))<="01001000";
					when "01000011"=>buf(conv_integer(wap))<="01001001";
					when "00111011"=>buf(conv_integer(wap))<="01001010";
					when "01000010"=>buf(conv_integer(wap))<="01001011";
					when "01001011"=>buf(conv_integer(wap))<="01001100";
					when "00111010"=>buf(conv_integer(wap))<="01001101";
					when "00110001"=>buf(conv_integer(wap))<="01001110";
					when "01000100"=>buf(conv_integer(wap))<="01001111";
					when "01001101"=>buf(conv_integer(wap))<="01010000";
					when "00010101"=>buf(conv_integer(wap))<="01010001";
					when "00101101"=>buf(conv_integer(wap))<="01010010";
					when "00011011"=>buf(conv_integer(wap))<="01010011";
					when "00101100"=>buf(conv_integer(wap))<="01010100";
					when "00111100"=>buf(conv_integer(wap))<="01010101";
					when "00101010"=>buf(conv_integer(wap))<="01010110";
					when "00011101"=>buf(conv_integer(wap))<="01010111";
					when "00100010"=>buf(conv_integer(wap))<="01011000";
					when "00110101"=>buf(conv_integer(wap))<="01011001";
					when "00011010"=>buf(conv_integer(wap))<="01011010";--Z
					when "00101001"=>buf(conv_integer(wap))<="00100000";--SPACE
					when "01011010"=>buf(conv_integer(wap))<="00001010";--ENTER
					when "01100110"=>buf(conv_integer(wap))<="00001000";--BACKSPACE
					when "01110110"=>buf(conv_integer(wap))<="00011011";--ESCAPE
					when "11110000"=>
						stat<=break;
						wap<=wap;
					when "11100000"=>
						stat<=special;
						wap<=wap;
					when others=>
						wap<=wap;
					end case;
				when break=>
					stat<=normal;
				when special=>
					wap<=wap+1;
					case rec_bitvector(8 downto 1) is
					when "01110101"=>buf(conv_integer(wap))<="00010001";--UP
					when "01110010"=>buf(conv_integer(wap))<="00010010";--DOWN
					when "01101011"=>buf(conv_integer(wap))<="00010011";--LEFT
					when "01110100"=>buf(conv_integer(wap))<="00010100";--RIGHT
					when "11110000"=>
						stat<=special_break;
						wap<=wap;
					when others=>
						stat<=normal;
						wap<=wap;
					end case;
				when special_break=>
					stat<=normal;
				end case;
			end if;
		end if;
	end process;--Êý×ÖºÍ×ÖÄ¸µÄÉ¨ÃèÂë×ª»»ÎªASCIIÂë£»

	ascii<=buf(conv_integer(wap+7));

	process(reset,sys_clock)
	begin
		if reset='0' then
			rap<="000";
		elsif sys_clock'event and sys_clock='1' then
			BUS_cs<=isKey;
			if isKey='1' then
				BUS_q<=fifo_out;
			else
				BUS_q<=(others=>'Z');
			end if;
			if isKey='1' and not(rap=wap) then
				rap<=rap+1;
			end if;
		end if;
	end process;

	fifo_out<=(others=>'0') when rap=wap else "00000001"&buf(conv_integer(rap));
	isKey <='1' when BUS_addr(31 downto 0)="00000000100001000000010100001010" else '0';
	
	BUS_busy<='0' when BUS_cs='1' else 'Z';
	
	intr<='0' when rap=wap else '1';
    
end;
