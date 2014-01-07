library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fifo_uart is
	port(
		rdclk,rdreq:in std_logic;
		wrclk,wrreq:in std_logic;
		data:in std_logic_vector(7 downto 0);
		q:out std_logic_vector(7 downto 0);
		empty:buffer std_logic:='1';
		used:buffer std_logic_vector(7 downto 0)
	);
end;

architecture main of fifo_uart is

	component fifo_ram IS
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdclock		: IN STD_LOGIC ;
			wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wrclock		: IN STD_LOGIC ;
			wren		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;

signal pt_head:std_logic_vector(7 downto 0):="00000000";
signal pt_tail:std_logic_vector(7 downto 0):="00000000";

begin
	
	ram0:fifo_ram port map(data=>data,rdaddress=>pt_head,rdclock=>rdclk,
						wraddress=>pt_tail,wrclock=>not wrclk,wren=>'1',q=>q);
	
	used<=pt_tail-pt_head;
	
	process(rdclk)
	begin
		if rdclk'event and rdclk='0' then
			if rdreq='1' then
				if used="0" then
					empty<='1';
				else
					empty<='0';
					pt_head<=pt_head+1;
				end if;
			end if;
		end if;
	end process;
	
	process(wrclk)
	begin
		if wrclk'event and wrclk='1' then
			if wrreq='1' and not ((pt_tail+1)=pt_head) then
				pt_tail<=pt_tail+1;
			end if;
		end if;
	end process;

end;