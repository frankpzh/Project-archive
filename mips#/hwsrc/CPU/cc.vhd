library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--cache controller
entity cc is
	PORT
	(
		clk,sync:in std_logic;
		
		--FCRH
		CC_en:in std_logic;
		PC:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		CC_busy:buffer std_logic;
		
		--CU
		CU_en:out std_logic;
		CU_inst:OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		
		--BC
		bus_cs:buffer std_logic:='0';
		bus_addr:out std_logic_vector(31 downto 0);
		bus_q:in std_logic_vector(15 downto 0);
		bus_busy:in std_logic
	);
end;

architecture main of cc is
	
	component cache_ram IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;

	component cachesign_ram IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
		);
	END component;
	
type stat_type is (A, B, C, D, E, F);
signal stat:stat_type:=A;

signal B0_wren,B1_wren,S_wren:std_logic;
signal S_data,S_q:std_logic_vector(47 downto 0);
signal B0_addr,B1_addr,S_addr:std_logic_vector(8 downto 0);
signal B0_data,B1_data,B0_q,B1_q,cache_q:std_logic_vector(15 downto 0);

begin
	
	bank0:cache_ram port map(address=>B0_addr,clock=>clk,data=>B0_data,
							wren=>B0_wren,q=>B0_q);
	bank1:cache_ram port map(address=>B1_addr,clock=>clk,data=>B1_data,
							wren=>B1_wren,q=>B1_q);
	sign:cachesign_ram port map(address=>S_addr,clock=>clk,data=>S_data,
							wren=>S_wren,q=>S_q);
	
	process(stat, clk, PC, S_q, bus_q)
	begin
		B0_addr<=PC(8 downto 0);
		B1_addr<=PC(8 downto 0);
		S_addr<=PC(8 downto 0);
		B0_data<=(others=>'0');
		B1_data<=(others=>'0');
		S_data<=(others=>'0');
		B0_wren<='0';
		B1_wren<='0';
		S_wren<='0';
		
		if clk='0' then
			case stat is
			when B=>
				if S_q(45 downto 23)=PC(31 downto 9) then
					S_data<="00"&S_q(45 downto 0);
					S_wren<='1';
				elsif S_q(22 downto 0)=PC(31 downto 9) then
					S_data<="01"&S_q(45 downto 0);
					S_wren<='1';
				end if;
			when F=>
				if S_q(46)='0' then
					S_data<="00"&PC(31 downto 9)&S_q(22 downto 0);
					S_wren<='1';
					B0_data<=bus_q;
					B0_wren<='1';
				else
					S_data<="01"&S_q(45 downto 23)&PC(31 downto 9);
					S_wren<='1';
					B1_data<=bus_q;
					B1_wren<='1';
				end if;
			when others=>
			end case;
		end if;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			case stat is
			when A=>
				if sync='1' and CC_en='1' then
					CC_busy<='1';
					CU_en<='0';
					stat<=B;
				end if;
			when B=>
				if S_q(45 downto 23)=PC(31 downto 9) then
					CC_busy<='0';
					CU_inst<=B0_q;
					CU_en<='1';
					stat<=A;
				elsif S_q(22 downto 0)=PC(31 downto 9) then
					CC_busy<='0';
					CU_inst<=B1_q;
					CU_en<='1';
					stat<=A;
				else
					stat<=C;
				end if;
			when C=>
				bus_addr<=PC;
				bus_cs<='1';
				stat<=D;
			when D=>
				stat<=E;
			when E=>
				stat<=F;
			when F=>
				if bus_busy='0' then
					bus_cs<='0';
					CC_busy<='0';
					CU_inst<=bus_q;
					CU_en<='1';
					stat<=A;
				else
					stat<=F;
				end if;
			end case;
		end if;
	end process;
	
end;