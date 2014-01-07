library ieee;
use ieee.std_logic_1164.all;

--Central Process Unit
entity cpu is
	port (
		uart_clk,step,reset:in std_logic;
		
		out_addr:out std_logic_vector(27 downto 0);
		
		rxd:in std_logic;
		txd:out std_logic;
		
		SRAM_addr:out std_logic_vector(17 downto 0);
		SRAM_data:out std_logic_vector(15 downto 0);
		SRAM_q:in std_logic_vector(15 downto 0);
		SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:out std_logic
	);
end;

architecture main of cpu is

	component decoder is
		port(
			bits:in std_logic_vector(3 downto 0);
			seven:out std_logic_vector(6 downto 0)
		);
	end component;

	component FCRH is
		port (
			clk,reset:in std_logic;
			
			--CC
			CC_busy:in std_logic;
			NPC:buffer std_logic_vector(14 downto 0):=(others=>'1');
			
			--CU
			PC:buffer std_logic_vector(14 downto 0):=(others=>'1');
			NPC_data:in std_logic_vector(14 downto 0);
			NPC_en:in std_logic;
			T_en,T_in:in std_logic;
			T_out:out std_logic;
			REG_data:out std_logic_vector(127 downto 0);
			
			--ALU
			REG_alu_id:in std_logic_vector(2 downto 0);
			REG_alu_in:in std_logic_vector(15 downto 0);
			REG_alu_en:in std_logic;
			
			--MC
			REG_mc_id:in std_logic_vector(2 downto 0);
			REG_mc_in:in std_logic_vector(15 downto 0);
			REG_mc_en:in std_logic
		);
	end component;

	component alu is
		port(
			rd:in std_logic_vector(2 downto 0);
			A,B:in std_logic_vector(15 downto 0);
			sign:in std_logic_vector(3 downto 0);
			
			dest:out std_logic_vector(2 downto 0);
			Q:out std_logic_vector(15 downto 0);
			en_Q:out std_logic
		);
	end component;

	component cu is
		port(
			clk,isinst:std_logic;
		
			inst:in std_logic_vector(15 downto 0);
			PC:in std_logic_vector(14 downto 0);
			
			REG_data:in std_logic_vector(127 downto 0);
			
			NPC:out std_logic_vector(14 downto 0);
			en_NPC:out std_logic;
			
			dest:out std_logic_vector(2 downto 0);
			A,B:out std_logic_vector(15 downto 0);
			sign:out std_logic_vector(3 downto 0);
			
			T,T_en:out std_logic;
			oldT:in std_logic;
		
			memreq,data_we:out std_logic;
			data_reg:out STD_LOGIC_VECTOR (2 DOWNTO 0);
			data_addr:out STD_LOGIC_VECTOR (31 DOWNTO 0);
			data_data:out STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	end component;

	COMPONENT cc IS
		PORT
		(
			--FCRH
			busy:out std_logic;
			PC:IN STD_LOGIC_VECTOR (14 DOWNTO 0);
			
			--CU
			CU_inst:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			CU_en:out std_logic;
			
			--BC
			bus_cs:out std_logic;
			bus_addr:out std_logic_vector(31 downto 0);
			bus_q:in std_logic_vector(15 downto 0);
			bus_busy:in std_logic
		);
	END COMPONENT;

	component bc is
		PORT(
			clk,uart_clk:in std_logic;

			--MC
			MC_cs,MC_we:in std_logic;
			MC_data:in STD_LOGIC_VECTOR (15 DOWNTO 0);
			MC_q:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			MC_addr:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			MC_busy,MC_written:out std_logic;

			--CC
			CC_cs:in std_logic;
			CC_q:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			CC_addr:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			CC_busy:out std_logic;
			
			--Peripherals
			rxd:in std_logic;
			txd:out std_logic;
			
			SRAM_addr:out std_logic_vector(17 downto 0);
			SRAM_data:out std_logic_vector(15 downto 0);
			SRAM_q:in std_logic_vector(15 downto 0);
			SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:buffer std_logic
		);
	end component;

	component mc is
		port(
			--CU
			CU_cs,CU_we:in std_logic;
			CU_reg:in STD_LOGIC_VECTOR (2 DOWNTO 0);
			CU_addr:in STD_LOGIC_VECTOR (31 DOWNTO 0);
			CU_data:in STD_LOGIC_VECTOR (15 DOWNTO 0);
			
			--BC
			BUS_cs,BUS_we:out std_logic;
			BUS_addr:out std_logic_vector(31 downto 0);
			BUS_data:out std_logic_vector(15 downto 0);
			BUS_busy,BUS_written:in std_logic;
			BUS_q:in std_logic_vector(15 downto 0);
			
			--FCRH
			REG_id:out std_logic_vector(2 downto 0);
			REG_in:out std_logic_vector(15 downto 0);
			REG_en:out std_logic		
		);
	end component;

signal en_NPC,ren:std_logic;
signal sign:std_logic_vector(3 downto 0);
signal PC,NPC,RPC:std_logic_vector(14 downto 0);
signal in_dest,dest:std_logic_vector(2 downto 0);
signal inst,q,A,B:std_logic_vector(15 downto 0);
signal regs:std_logic_vector(127 downto 0);

signal todata_we,data_we,data_busy,inst_busy,T_en:std_logic;
signal inst_en,inst_cs,data_cs,CC_busy,MC_cs,BUS_written:std_logic;
signal todata_addr,inst_addr,data_addr:std_logic_vector(31 downto 0);
signal todata_data,inst_q,data_data,data_q:std_logic_vector(15 downto 0);
signal todata_reg:std_logic_vector(2 downto 0);

signal REG_mc_id:std_logic_vector(2 downto 0);
signal REG_mc_in:std_logic_vector(15 downto 0);
signal REG_mc_en,T_old,T_new:std_logic;

begin

	CU_0:cu port map(NPC=>NPC,en_NPC=>en_NPC,inst=>inst,REG_data=>regs,
					clk=>step,PC=>PC,dest=>in_dest,A=>A,B=>B,sign=>sign,
					isinst=>inst_en,memreq=>MC_cs,data_we=>todata_we,
					data_addr=>todata_addr,data_reg=>todata_reg,
					data_data=>todata_data,oldT=>T_old,T=>T_new,T_en=>T_en);
	
	ALU_0:alu port map(rd=>in_dest,A=>A,B=>B,sign=>sign,
					dest=>dest,Q=>q,en_Q=>ren);
	
	CC_0:cc port map(PC=>RPC,CU_inst=>inst,CU_en=>inst_en,
					bus_busy=>inst_busy,bus_addr=>inst_addr,
					bus_q=>inst_q,bus_cs=>inst_cs,busy=>CC_busy);
	
	BC_0:bc port map(MC_we=>data_we,MC_data=>data_data,
					MC_q=>data_q,CC_q=>inst_q,MC_addr=>data_addr,
					CC_addr=>inst_addr,SRAM_addr=>SRAM_addr,
					SRAM_data=>SRAM_data,SRAM_q=>SRAM_q,
					SRAM_n_we=>SRAM_n_we,SRAM_n_oe=>SRAM_n_oe,
					SRAM_n_ce=>SRAM_n_ce,SRAM_n_ub=>SRAM_n_ub,
					SRAM_n_lb=>SRAM_n_lb,clk=>step,rxd=>rxd,txd=>txd,
					uart_clk=>uart_clk,MC_busy=>data_busy,
					CC_busy=>inst_busy,MC_cs=>data_cs,
					CC_cs=>inst_cs,MC_written=>BUS_written);
	
	MC_0:mc port map(REG_id=>REG_mc_id,REG_in=>REG_mc_in,REG_en=>REG_mc_en,
					BUS_we=>data_we,BUS_data=>data_data,BUS_q=>data_q,
					BUS_addr=>data_addr,CU_we=>todata_we,CU_reg=>todata_reg,
					CU_addr=>todata_addr,CU_data=>todata_data,CU_cs=>MC_cs,
					BUS_cs=>data_cs,BUS_busy=>data_busy,BUS_written=>BUS_written);
	
	FCRH_0:FCRH port map(clk=>step,reset=>reset,NPC_data=>NPC,
					NPC_en=>en_NPC,PC=>PC,NPC=>RPC,REG_data=>regs,
					REG_alu_id=>dest,REG_alu_in=>q,REG_alu_en=>ren,
					REG_mc_id=>REG_mc_id,REG_mc_in=>REG_mc_in,
					REG_mc_en=>REG_mc_en,T_in=>T_new,T_out=>T_old,
					CC_busy=>CC_busy,T_en=>T_en);
	
	u5:decoder port map(bits=>PC(3 downto 0),seven=>out_addr(6 downto 0));
	u6:decoder port map(bits=>PC(7 downto 4),seven=>out_addr(13 downto 7));
	u7:decoder port map(bits=>PC(11 downto 8),seven=>out_addr(20 downto 14));
	u8:decoder port map(bits=>'0'&PC(14 downto 12),seven=>out_addr(27 downto 21));

end;