library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Flow Controller & Register Holder
entity FCRH is
	port (
		clk,reset_n:in std_logic;
		
		--Interrupt
		INT:in std_logic;
		INT_commit:out std_logic;
		NPC_IPC_en:buffer std_logic:='0';
		NPC_IPC:buffer std_logic_vector(31 downto 0):=(others=>'0');
		IPC:in std_logic_vector(31 downto 0);
		
		--CC
		CC_en:out std_logic;
		PC:buffer std_logic_vector(31 downto 0):=(others=>'1');
		CC_busy:in std_logic;
		
		--CU
		Bubble:in std_logic;
		PC_cu:buffer std_logic_vector(31 downto 0);
		NPC_en:in std_logic;
		NPC_data:in std_logic_vector(31 downto 0);
		T_en,T_in:in std_logic;
		T_out,inst_en:out std_logic;
		REG_data:out std_logic_vector(127 downto 0);
		REG_last_en:out std_logic;
		REG_last:out std_logic_vector(2 downto 0);
		REG_change_en:in std_logic;
		REG_change:in std_logic_vector(2 downto 0);
		
		--ALU
		C_in:in std_logic;
		C_out:out std_logic;
		REG_alu_id:in std_logic_vector(2 downto 0);
		REG_alu_in:in std_logic_vector(15 downto 0);
		REG_alu_en:in std_logic;
		REG_data_last:out std_logic_vector(15 downto 0);
		
		--MC
		MC_busy:in std_logic;
		REG_mc_id:in std_logic_vector(2 downto 0);
		REG_mc_in:in std_logic_vector(15 downto 0);
		REG_mc_en:in std_logic;
		
		--Door
		door1,door2,door2_clr:buffer std_logic
	);
end;

architecture main of FCRH is

signal REG_id:std_logic_vector(2 downto 0);
signal REG_in:std_logic_vector(15 downto 0);
signal NPC_save,GPC:std_logic_vector(31 downto 0);
signal REG_en,NPC_valid,NPC_delay,INT_delay,INT_valid:std_logic:='0';

begin
	
	door1<=not (MC_busy or Bubble);
	door2<=not (MC_busy or Bubble);
	door2_clr<=not MC_busy;
	
	--有效的NPC信号
	NPC_valid<=(not Bubble) and NPC_en;
	
	--这里要处理PC NPC INT三者之间的关系
	--无论是NPC还是INT，都必须等CC_busy结束后才commit
	--NPC_delay表示CU发送了有效的NPC信号，但是由于CC_busy所以没有处理
	--INT_delay表示外部发送了有效的中断，但是由于CC_busy所以没有处理
	--INT_open表示中断是否打开
	GPC<=NPC_save	when NPC_delay='1' else
		NPC_data	when NPC_valid='1' else
		PC+1;
	
	CC_en<='0' when (CC_busy='0' and door1='0') or reset_n='0' else '1';

	process(clk,reset_n)
	begin
		if reset_n='0' then
			PC<=(others=>'1');
			NPC_delay<='0';
			INT_delay<='0';
			inst_en<='1';
		elsif clk'event and clk='1' then
			INT_commit<='0';
			
			if (CC_busy='0') and (door1='1') then
				--供CU使用的PC
				PC_cu<=PC;

				--是中断跳转还是正常运行
				if (INT_delay or INT)='1' then
					--处理两次连续中断的情况
					if NPC_IPC_en='1' then
						PC<=NPC_IPC;
					else
						PC<=IPC;
					end if;
					
					--中断触发
					INT_commit<='1';
					--让IPC模块接收NPC_IPC，该信号在中断来临时，上升沿后有效，持续1周期
					NPC_IPC_en<='1';
					--NPC_IPC为当前正在指令槽的指令地址
					if (NPC_delay or NPC_valid)='1' then
						NPC_IPC<=GPC;
					else
						NPC_IPC<=PC;
					end if;
					--屏蔽指令槽中的那条指令
					inst_en<='0';
				else
					PC<=GPC;
					NPC_IPC_en<='0';
					--跳转将屏蔽指令槽中的那条指令
					inst_en<=not (NPC_valid or NPC_delay);
				end if;
				--清NPC_delay和INT_delay
				NPC_delay<='0';
				INT_delay<='0';
			else
				--CC_busy时，置NPC_delay，保存NPC_data
				if NPC_valid='1' then
					NPC_save<=NPC_data;
					NPC_delay<='1';
				end if;
				--CC_busy时，置INT_delay
				if INT='1' then
					INT_delay<='1';
				end if;
				NPC_IPC_en<='0';
			end if;
		end if;
	end process;

	process(clk,reset_n)
	begin
		if reset_n='0' then
			REG_last_en<='0';
			T_out<='0';
			C_out<='0';
		elsif clk'event and clk='1' then
			
			if door2='1' then
				REG_last<=REG_change;
				REG_last_en<=REG_change_en;
			elsif door2_clr='1' then
				REG_last_en<='0';
			end if;
			
			--当CU有效并且door1开放时，commit T
			if T_en='1' and door1='1' then
				T_out<=T_in;
			end if;
			
			--ALU中的内容只available一周期，所以直接commit C
			C_out<=C_in;
			
		end if;
	end process;
	
	REG_en<=REG_alu_en or REG_mc_en;
	REG_id<=REG_alu_id when REG_alu_en='1' else REG_mc_id;
	REG_in<=REG_alu_in when REG_alu_en='1' else REG_mc_in;
	
	process(clk,reset_n)
	begin
		if reset_n='0' then
			REG_data<=(others=>'0');
		elsif clk'event and clk='1' then
			if REG_en='1' then
				case REG_id is
					when "000"=>
						REG_data(15 downto 0)<=REG_in;
					when "001"=>
						REG_data(31 downto 16)<=REG_in;
					when "010"=>
						REG_data(47 downto 32)<=REG_in;
					when "011"=>
						REG_data(63 downto 48)<=REG_in;
					when "100"=>
						REG_data(79 downto 64)<=REG_in;
					when "101"=>
						REG_data(95 downto 80)<=REG_in;
					when "110"=>
						REG_data(111 downto 96)<=REG_in;
					when "111"=>
						REG_data(127 downto 112)<=REG_in;
				end case;
				--For Forwarding
				REG_data_last<=REG_in;
			end if;
		end if;
	end process;
	
end;