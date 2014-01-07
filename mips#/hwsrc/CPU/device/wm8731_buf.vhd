library ieee;
use ieee.std_logic_1164.all;

entity wm8731_buf is
	port (
		clk,reset:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--Interrupt(High)
		Half_Empty:buffer std_logic;
		
		--WM8731
		rd_empty:out std_logic;
		rd_clk,rd_en:in std_logic;
		rd_q:out std_logic_vector(15 downto 0)
	);
end;

architecture main of wm8731_buf is

	component fifo_wm8731 IS
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrusedw		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
		);
	END component;

signal cs,wr_en,int_en:std_logic:='0';
signal wrusedw:std_logic_vector(8 downto 0);
signal data_reg:std_logic_vector(15 downto 0);

begin

	process(clk,reset)
	begin
		if reset='0' then
			wr_en<='0';
			int_en<='0';
			data_reg<=(others=>'0');
		elsif clk'event and clk='1' then
		
			data_reg<=BUS_data;
			
			if BUS_addr(31 downto 1)="0000000010000100000001010000111" then
				cs<='1';
				if BUS_addr(0)='1' then
					wr_en<='0';
					if BUS_we='1' then
						int_en<=BUS_data(0);
					end if;
				else
					wr_en<='1';
				end if;
			else
				cs<='0';
				wr_en<='0';
			end if;
			
		end if;
	end process;
	
	BUS_busy<='0' when cs='1' else 'Z';
	BUS_q<="000000000000000"&Half_Empty when cs='1' else (others=>'Z');
	
	u0:fifo_wm8731 port map(rdempty=>rd_empty,rdclk=>rd_clk,rdreq=>rd_en,q=>rd_q,
						wrclk=>not clk,wrreq=>wr_en,data=>data_reg,wrusedw=>wrusedw);
	Half_Empty<=not wrusedw(8) and int_en;

end;