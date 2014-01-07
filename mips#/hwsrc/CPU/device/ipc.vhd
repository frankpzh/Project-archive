library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ipc is
	port(
		clk:in std_logic;
		
		--BUS
		BUS_we:in std_logic;
		BUS_addr:in std_logic_vector(31 downto 0);
		BUS_data:in std_logic_vector(15 downto 0);
		BUS_q:inout std_logic_vector(15 downto 0);
		BUS_busy:inout std_logic;
		
		--ipc
		INT_en:in std_logic;
		NPC:in std_logic_vector(31 downto 0);
		IPC:buffer std_logic_vector(31 downto 0):=(others=>'0')
	);
end;

architecture main of ipc is

signal ch1, ch2:std_logic:='0';
signal IPC_new:std_logic_vector(31 downto 0);

signal cs:std_logic;
signal q:std_logic_vector(15 downto 0);

begin
	
	process(clk)
	begin
		if clk'event and clk='0' then
			if INT_en='1' then
				ch1<=not ch2;
				IPC_new<=NPC;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if BUS_addr(31 downto 1)="0000000010000100000001010000110" then
				cs<='1';
				if BUS_we='1' then
					if BUS_addr(0)='0' then
						IPC(15 downto 0)<=BUS_data;
					else
						IPC(31 downto 16)<=BUS_data;
					end if;
				end if;
			else
				cs<='0';
				if not ch1=ch2 then
					IPC<=IPC_new;
					ch2<=ch1;
				end if;
			end if;
		end if;
	end process;
	
	BUS_busy<='0' when cs='1' else 'Z';
	BUS_q<=q when cs='1' else (others=>'Z');
	q<=IPC(31 downto 16) when BUS_addr(0)='1' else IPC(15 downto 0);
	
end;