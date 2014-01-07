library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cu is
	port(
		--CC
		inst_en:in std_logic;
		inst:in std_logic_vector(15 downto 0);
		
		--FCRH
		Bubble:buffer std_logic;
		PC:in std_logic_vector(31 downto 0);
		REG_data:in std_logic_vector(127 downto 0);
		NPC:out std_logic_vector(31 downto 0);
		NPC_en:out std_logic;
		T_new,T_en:out std_logic;
		T_old,FCRH_en:in std_logic;
		
		REG_last_en:in std_logic;
		REG_last:in std_logic_vector(2 downto 0);
		REG_change_en:out std_logic;
		REG_change:out std_logic_vector(2 downto 0);
		
		--Interrupt(High)
		INT_code:in std_logic_vector(3 downto 0);
		INT_en:out std_logic;
		
		--ALU
		ALU_C:in std_logic;
		ALU_dest:buffer std_logic_vector(2 downto 0);
		A,B:out std_logic_vector(15 downto 0);
		ALU_sign:buffer std_logic_vector(3 downto 0);
		ALU_Loopback:out std_logic_vector(1 downto 0);
		
		--MC
		MC_cs,MC_we:buffer std_logic;
		MC_reg:buffer STD_LOGIC_VECTOR (2 DOWNTO 0);
		MC_addr:out STD_LOGIC_VECTOR (31 DOWNTO 0);
		MC_data:out STD_LOGIC_VECTOR (15 DOWNTO 0);
		MC_Loopback:out std_logic
	);
end;

architecture main of cu is

	component offsetter is
		port(
			PC:in std_logic_vector(31 downto 0);
			offset:in std_logic_vector(10 downto 0);
			NPC:out std_logic_vector(31 downto 0)
		);
	end component;

	component offsetter_s is
		port(
			PC:in std_logic_vector(31 downto 0);
			offset:in std_logic_vector(7 downto 0);
			NPC:out std_logic_vector(31 downto 0)
		);
	end component;

	component offsetter_5 is
		port(
			PC:in std_logic_vector(15 downto 0);
			offset:in std_logic_vector(4 downto 0);
			NPC:out std_logic_vector(15 downto 0)
		);
	end component;

signal CU_en,RS_dirty,RD_dirty,SEG_Dirty,SP_dirty:std_logic;

signal NPC1,NPC2,RPC:std_logic_vector(31 downto 0);

signal MC_addr_s:std_logic_vector(31 downto 0);
signal MC_addr_lw:std_logic_vector(15 downto 0);

signal rs,rd:std_logic_vector(15 downto 0);
signal imm_sign,rd_sign:std_logic_vector(7 downto 0);
signal imm_s,imm_u:std_logic_vector(15 downto 0);
signal comp_res:std_logic_vector(5 downto 0);

signal ALU_sign_org:std_logic_vector(3 downto 0);

begin
	
	CU_en<=inst_en and FCRH_en;
	T_en<=CU_en and not Bubble;
	
	ALU_sign<=ALU_sign_org when Bubble='0' else "1111";
	
	RS_dirty<='1' when REG_last_en='1' and REG_last=inst(7 downto 5) else '0';
	RD_dirty<='1' when REG_last_en='1' and REG_last=inst(10 downto 8) else '0';
	SEG_dirty<='1' when REG_last_en='1' and REG_last="100" else '0';
	SP_dirty<='1' when REG_last_en='1' and (REG_last="101" or REG_last="110") else '0';
	
	REG_change_en<=not MC_we when MC_cs='1' else
					'1' when ALU_sign<="1100" else '0';
	REG_change<=MC_reg when MC_cs='1' else ALU_dest;
	
	process(CU_en,inst,rs,rd,comp_res,NPC1,NPC2,PC,T_old,rd_sign,
			imm_s,imm_u,RS_dirty,RD_dirty,SEG_Dirty,RPC,REG_data,
			SP_dirty,REG_last_en,ALU_C,MC_addr_lw,MC_addr_s,INT_code)
	begin
		
		INT_en<='0';
		NPC<=(others=>'0');
		NPC_en<='0';
		
		ALU_sign_org<="1111";
		A<=(others=>'0');
		B<=(others=>'0');
		ALU_dest<=inst(10 downto 8);
		ALU_Loopback<="00";
		
		MC_cs<='0';
		MC_addr<=(others=>'0');
		MC_we<='0';
		MC_data<=(others=>'0');
		MC_reg<=(others=>'0');
		MC_Loopback<='0';

		T_new<=T_old;
		Bubble<='0';
		
		if CU_en='1' then
			case inst(15 downto 11) is
			when "00000"=>		--RRF
				case inst(3 downto 0) is
				when "0000"=>	--move
					A<=rs;
					ALU_sign_org<="0000";
					ALU_Loopback<='0'&RS_dirty;
				when "0001"=>	--srav
					A<=rd;
					B<=rs;
					ALU_sign_org<="0011";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "0010"=>	--sllv
					A<=rd;
					B<=rs;
					ALU_sign_org<="0010";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "0011"=>	--neg
					A<=rs;
					ALU_sign_org<="0100";
					ALU_Loopback<='0'&RS_dirty;
				when "0100"=>	--srlv
					A<=rd;
					B<=rs;
					ALU_sign_org<="0001";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "0101"=>	--not
					A<=rs;
					ALU_sign_org<="0111";
					ALU_Loopback<='0'&RS_dirty;
				when "0110"=>	--add
					A<=rd;
					B<=rs;
					ALU_sign_org<="0101";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "0111"=>	--sub
					A<=rd;
					B<=rs;
					ALU_sign_org<="0110";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "1000"=>	--slt
					T_new<=comp_res(4);
					Bubble<=RD_dirty or RS_dirty;
				when "1001"=>	--sltu
					T_new<=comp_res(5);
					Bubble<=RD_dirty or RS_dirty;
				when "1010"=>	--and
					A<=rd;
					B<=rs;
					ALU_sign_org<="1000";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "1011"=>	--or
					A<=rd;
					B<=rs;
					ALU_sign_org<="1001";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "1100"=>	--xor
					A<=rd;
					B<=rs;
					ALU_sign_org<="1010";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "1101"=>	--cmp
					T_new<=comp_res(3);
					Bubble<=RD_dirty or RS_dirty;
				when "1110"=>	--adc
					A<=rd;
					B<=rs;
					ALU_sign_org<="1011";
					ALU_Loopback<=RS_dirty&RD_dirty;
				when "1111"=>	--sbb
					A<=rd;
					B<=rs;
					ALU_sign_org<="1100";
					ALU_Loopback<=RS_dirty&RD_dirty;
				end case;
			when "00010"=>		--lw
				MC_cs<=not (RS_dirty or SEG_dirty);
				MC_addr<=REG_data(79 downto 64)&MC_addr_lw;
				MC_reg<=inst(10 downto 8);
				Bubble<=RS_dirty or SEG_dirty;
			when "00011"=>		--sw
				MC_cs<=not (RS_dirty or SEG_dirty);
				MC_addr<=REG_data(79 downto 64)&MC_addr_lw;
				MC_we<='1';
				MC_data<=rd;
				MC_Loopback<=RD_dirty;
				Bubble<=RS_dirty or SEG_dirty;
			when "00100"=>		--zeb
				A<="00000000"&rd(7 downto 0);
				ALU_sign_org<="0000";
				Bubble<=RD_dirty;
			when "00101"=>		--seb
				A<=rd_sign&rd(7 downto 0);
				ALU_sign_org<="0000";
				Bubble<=RD_dirty;
			when "00110"=>		--ls
				MC_cs<=not SP_dirty;
				MC_addr<=MC_addr_s;
				MC_reg<=inst(10 downto 8);
				Bubble<=SP_dirty;
			when "00111"=>		--ss
				MC_cs<=not SP_dirty;
				MC_addr<=MC_addr_s;
				MC_we<='1';
				MC_data<=rd;
				MC_Loopback<=RD_dirty;
				Bubble<=SP_dirty;
			when "01000"=>
				case inst(1 downto 0) is
				when "00"=>		--int
					INT_en<='1';
				when "01"=>		--cli
				when "10"=>		--sti
				when "11"=>		--ictr
					A<="000000000000"&INT_code;
					ALU_sign_org<="0000";
				end case;
				
			when "01001"=>		--clc
				ALU_sign_org<="1101";
			when "01010"=>		--stc
				ALU_sign_org<="1110";
			when "01011"=>		--hide
				MC_cs<=not REG_last_en;
				MC_addr<="00000000100001000000010100010000"+inst(9 downto 5);
				MC_we<=inst(10);
				if inst(9 downto 8)="00" then
					MC_data<=rs;
				else
					MC_data<="00000000000000"&T_old&ALU_C;
				end if;
				MC_reg<=inst(7 downto 5);
				Bubble<=REG_last_en;
			when "01100"=>		--sra
				A<=rd;
				B<="000000000000"&inst(7 downto 4);
				ALU_sign_org<="0011";
				ALU_Loopback<='0'&RD_dirty;
			when "01101"=>		--sll
				A<=rd;
				B<="000000000000"&inst(7 downto 4);
				ALU_sign_org<="0010";
				ALU_Loopback<='0'&RD_dirty;
			when "01110"=>		--srl
				A<=rd;
				B<="000000000000"&inst(7 downto 4);
				ALU_sign_org<="0001";
				ALU_Loopback<='0'&RD_dirty;
			when "10000"=>		--addi
				A<=rd;
				B<=imm_u;
				ALU_sign_org<="0101";
				ALU_Loopback<='0'&RD_dirty;
			when "10001"=>		--slti
				T_new<=comp_res(1);
				Bubble<=RD_dirty;
			when "10010"=>		--sltiu
				T_new<=comp_res(2);
				Bubble<=RD_dirty;
			when "10011"=>		--lui
				A<=inst(7 downto 0)&"00000000";
				ALU_sign_org<="0000";
			when "10100"=>		--li
				A<=imm_u;
				ALU_sign_org<="0000";
			when "10101"=>		--cmpi
				T_new<=comp_res(0);
				Bubble<=RD_dirty;
			when "10110"=>		--adci
				A<=rd;
				B<=imm_u;
				ALU_sign_org<="1011";
				ALU_Loopback<='0'&RD_dirty;
			when "10111"=>		--sbbi
				A<=rd;
				B<=imm_u;
				ALU_sign_org<="1100";
				ALU_Loopback<='0'&RD_dirty;
			when "11000"=>		--b
				NPC<=NPC1;
				NPC_en<='1';
			when "11001"=>		--jal
				ALU_dest<="111";
				A<=RPC(15 downto 0);
				ALU_sign_org<="0000";
				NPC<=NPC1;
				NPC_en<='1';
			when "11010"=>		--bteqz
				NPC<=NPC1;
				NPC_en<=not T_old;
			when "11011"=>		--btnez
				NPC<=NPC1;
				NPC_en<=T_old;
			when "11100"=>		--jr
				ALU_dest<="111";
				A<=RPC(15 downto 0);
				ALU_sign_org<="0000";
				NPC(31 downto 16)<=REG_data(79 downto 64);
				NPC(15 downto 0)<=rd;
				NPC_en<='1';
				Bubble<=RD_dirty or SEG_dirty;
			when "11101"=>		--jalr
				ALU_dest<="111";
				A<=RPC(15 downto 0);
				ALU_sign_org<="0000";
				NPC(31 downto 16)<=PC(31 downto 16);
				NPC(15 downto 0)<=rd;
				NPC_en<='1';
				Bubble<=RD_dirty;
			when "11110"=>		--beqz
				if rd="0000000000000000" then
					NPC_en<='1';
				else
					NPC_en<='0';
				end if;
				NPC<=NPC2;
				Bubble<=RD_dirty;
			when "11111"=>		--bnez
				if rd="0000000000000000" then
					NPC_en<='0';
				else
					NPC_en<='1';
				end if;
				NPC<=NPC2;
				Bubble<=RD_dirty;
			when others=>
			end case;
		end if;
	end process;
	
	rs<=REG_data(15 downto 0) when inst(7 downto 5)="000" else
		REG_data(31 downto 16) when inst(7 downto 5)="001" else
		REG_data(47 downto 32) when inst(7 downto 5)="010" else
		REG_data(63 downto 48) when inst(7 downto 5)="011" else
		REG_data(79 downto 64) when inst(7 downto 5)="100" else
		REG_data(95 downto 80) when inst(7 downto 5)="101" else
		REG_data(111 downto 96) when inst(7 downto 5)="110" else
		REG_data(127 downto 112);
		
	rd<=REG_data(15 downto 0) when inst(10 downto 8)="000" else
		REG_data(31 downto 16) when inst(10 downto 8)="001" else
		REG_data(47 downto 32) when inst(10 downto 8)="010" else
		REG_data(63 downto 48) when inst(10 downto 8)="011" else
		REG_data(79 downto 64) when inst(10 downto 8)="100" else
		REG_data(95 downto 80) when inst(10 downto 8)="101" else
		REG_data(111 downto 96) when inst(10 downto 8)="110" else
		REG_data(127 downto 112);
		
	rd_sign<=(others=>rd(7));
	imm_sign<=(others=>inst(7));
	imm_s<=imm_sign&inst(7 downto 0);
	imm_u<="00000000"&inst(7 downto 0);
	
	comp_res(0)<='0' when rd=imm_u else '1';
	comp_res(1)<='1' when signed(rd)<signed(imm_s) else '0';
	comp_res(2)<='1' when unsigned(rd)<unsigned(imm_u) else '0';
	
	comp_res(3)<='0' when rd=rs else '1';
	comp_res(4)<='1' when signed(rd)<signed(rs) else '0';
	comp_res(5)<='1' when unsigned(rd)<unsigned(rs) else '0';

	offset_0:offsetter port map(PC=>RPC,offset=>inst(10 downto 0),NPC=>NPC1);
	offset_1:offsetter_s port map(PC=>RPC,offset=>inst(7 downto 0),NPC=>NPC2);
	offset_2:offsetter_5 port map(PC=>rs,offset=>inst(4 downto 0),NPC=>MC_addr_lw);
	offset_3:offsetter_s port map(PC=>REG_data(95 downto 80)&REG_data(111 downto 96),
									offset=>inst(7 downto 0),NPC=>MC_addr_s);
	
	RPC<=PC+1;

end;