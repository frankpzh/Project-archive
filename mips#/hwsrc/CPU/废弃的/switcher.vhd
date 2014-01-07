library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity switcher is
	port(
		clk,reset,step_key:in std_logic;

		switch:in std_logic_vector(17 downto 16);
		seven_digit:out std_logic_vector(55 downto 28);
		
		rxd:in std_logic;
		txd:out std_logic;
		
		SRAM_addr:out std_logic_vector(17 downto 0);
		SRAM_data:inout std_logic_vector(15 downto 0);
		SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:buffer std_logic		
	);
end;

architecture main of switcher is

	component decoder is
		port(
			bits:in std_logic_vector(3 downto 0);
			seven:out std_logic_vector(6 downto 0)
		);
	end component;
	
	component uart_clk is
		port(
			clk50:in std_logic;
			uart_clk:buffer std_logic
		);
	end component;
	
	component ram_filler is
		port(
			clk,rxd,reset,uart_clk:in std_logic;
			
			out_addr:out std_logic_vector(27 downto 0);
			
			SRAM_addr:out std_logic_vector(17 downto 0);
			SRAM_data:out std_logic_vector(15 downto 0);
			SRAM_q:in std_logic_vector(15 downto 0);
			SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:out std_logic		
		);
	end component;

	component cpu is
		port (
			clk,clk_2times,uart_clk,reset:in std_logic;
			
			PC:out std_logic_vector(14 downto 0);
			
			rxd:in std_logic;
			txd:out std_logic;
			
			SRAM_addr:out std_logic_vector(17 downto 0);
			SRAM_data:out std_logic_vector(15 downto 0);
			SRAM_q:in std_logic_vector(15 downto 0);
			SRAM_n_we,SRAM_n_oe,SRAM_n_ub,SRAM_n_lb,SRAM_n_ce:out std_logic
		);
	end component;

signal uclk,step_clk,step:std_logic;
signal counter:std_logic_vector(7 downto 0);

signal PC:std_logic_vector(14 downto 0);
signal step_cpu,reset_cpu,rxd_cpu:std_logic;
signal digit_cpu:std_logic_vector(27 downto 0);
signal SRAM_addr_cpu:std_logic_vector(17 downto 0);
signal SRAM_data_cpu,SRAM_q_cpu:std_logic_vector(15 downto 0);
signal SRAM_n_we_cpu,SRAM_n_oe_cpu,SRAM_n_ub_cpu,SRAM_n_lb_cpu,SRAM_n_ce_cpu:std_logic;

signal reset_ram,rxd_ram:std_logic;
signal digit_ram:std_logic_vector(27 downto 0);
signal SRAM_addr_ram:std_logic_vector(17 downto 0);
signal SRAM_data_ram,SRAM_q_ram:std_logic_vector(15 downto 0);
signal SRAM_n_we_ram,SRAM_n_oe_ram,SRAM_n_ub_ram,SRAM_n_lb_ram,SRAM_n_ce_ram:std_logic;

begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
--			counter<=counter+1;
--			if counter="0" then
				step_clk<=not step_clk;
--			end if;
		end if;
	end process;
	
	step<=step_key when switch(16)='0' else step_clk;
	
	uart_clk0:uart_clk port map(clk50=>clk,uart_clk=>uclk);
	
	cpu0:cpu port map(clk=>step_cpu,reset=>reset_cpu,uart_clk=>uclk,
					SRAM_addr=>SRAM_addr_cpu,SRAM_data=>SRAM_data_cpu,
					SRAM_n_we=>SRAM_n_we_cpu,SRAM_n_oe=>SRAM_n_oe_cpu,
					SRAM_n_ub=>SRAM_n_ub_cpu,SRAM_n_lb=>SRAM_n_lb_cpu,
					SRAM_n_ce=>SRAM_n_ce_cpu,SRAM_q=>SRAM_q_cpu,
					PC=>PC,rxd=>rxd_cpu,txd=>txd,clk_2times=>clk);

	ram0:ram_filler port map(clk=>clk,reset=>reset_ram,uart_clk=>uclk,
					out_addr=>digit_ram,SRAM_n_ce=>SRAM_n_ce_ram,
					SRAM_addr=>SRAM_addr_ram,SRAM_data=>SRAM_data_ram,
					SRAM_n_we=>SRAM_n_we_ram,SRAM_n_oe=>SRAM_n_oe_ram,
					SRAM_n_ub=>SRAM_n_ub_ram,SRAM_n_lb=>SRAM_n_lb_ram,
					SRAM_q=>SRAM_q_ram,rxd=>rxd_ram);
	
	step_cpu<=step when switch(17)='0' else '0';
	reset_ram<=reset when switch(17)='1' else '0';
	reset_cpu<=reset when switch(17)='0' else '0';
	seven_digit(55 downto 28)<=digit_ram when switch(17)='1' else digit_cpu;
	rxd_ram<=rxd when switch(17)='1' else '1';
	rxd_cpu<=rxd when switch(17)='0' else '1';
	
	SRAM_addr<=SRAM_addr_ram when switch(17)='1' else SRAM_addr_cpu;
	SRAM_n_we<=SRAM_n_we_ram when switch(17)='1' else SRAM_n_we_cpu;
	SRAM_n_oe<=SRAM_n_oe_ram when switch(17)='1' else SRAM_n_oe_cpu;
	SRAM_n_ub<=SRAM_n_ub_ram when switch(17)='1' else SRAM_n_ub_cpu;
	SRAM_n_lb<=SRAM_n_lb_ram when switch(17)='1' else SRAM_n_lb_cpu;
	SRAM_n_ce<=SRAM_n_ce_ram when switch(17)='1' else SRAM_n_ce_cpu;
	
	SRAM_data<=(others=>'Z') when SRAM_n_we='1' else
				SRAM_data_ram when switch(17)='1' else 
				SRAM_data_cpu;
	
	SRAM_q_ram<=(others=>'0') when SRAM_n_we='0' or switch(17)='0' else
				SRAM_data;
	
	SRAM_q_cpu<=(others=>'0') when SRAM_n_we='0' or switch(17)='1' else
				SRAM_data;
	
	u5:decoder port map(bits=>PC(3 downto 0),seven=>digit_cpu(6 downto 0));
	u6:decoder port map(bits=>PC(7 downto 4),seven=>digit_cpu(13 downto 7));
	u7:decoder port map(bits=>PC(11 downto 8),seven=>digit_cpu(20 downto 14));
	u8:decoder port map(bits=>'0'&PC(14 downto 12),seven=>digit_cpu(27 downto 21));
end;