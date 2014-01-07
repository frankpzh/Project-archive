library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity musicmixer is
	port (
		clk,bigclk,reset:in std_logic;
		
		add_note:out std_logic_vector(6 downto 0);
		data_note:out std_logic_vector(31 downto 0);
		out_note:in std_logic_vector(31 downto 0);
		wren:out std_logic;
		
		output:out std_logic_vector(15 downto 0)
	);
end;

architecture main of musicmixer is

	component sinegenerater is
		port (
			clk,bigclk:in std_logic;
			address:in std_logic_vector(4 downto 0);
			
			add_note:buffer std_logic_vector(6 downto 0);
			data_note:out std_logic_vector(31 downto 0);
			out_note:in std_logic_vector(31 downto 0);
			wren:out std_logic:='0';
			
			output:out std_logic_vector(9 downto 0);
			done:out std_logic
		);
	end component;

type stat_type is (start,
					waitingdone,
					addresult,
					checknext,
					idle);
signal stat:stat_type;

signal sf,nsf:std_logic;

signal worker_clk,worker_done:std_logic;
signal worker_add:std_logic_vector(4 downto 0);
signal worker_out:std_logic_vector(9 downto 0);

signal save_output:std_logic_vector(15 downto 0);

begin

	u1: sinegenerater port map(clk=>clk,bigclk=>worker_clk,
							address=>worker_add,wren=>wren,
							data_note=>data_note,out_note=>out_note,
							add_note=>add_note,output=>worker_out,
							done=>worker_done);

	process(bigclk)
	begin
		if bigclk'event and bigclk='1' then
			sf<=not nsf;
		end if;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if sf=nsf then
				case stat is
					when start=>
						worker_add<=(others=>'0');
						save_output<=(others=>'0');
						worker_clk<='0';
						stat<=waitingdone;
						
					when waitingdone=>
						worker_clk<='1';
						if worker_done='1' then
							stat<=addresult;
						end if;
						
					when addresult=>
						save_output<=save_output+worker_out;
						stat<=checknext;
						worker_clk<='0';
						
					when checknext=>
						if worker_add=31 then
							output<=save_output;
							stat<=idle;
						else
							stat<=waitingdone;
						end if;
						worker_add<=worker_add+1;
						
					when others=>
				end case;
			else
				nsf<=sf;
				worker_clk<='0';
				stat<=start;
			end if;
		end if;
	end process;
	
end;