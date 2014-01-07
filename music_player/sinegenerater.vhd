library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sinegenerater is
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
end;

architecture main of sinegenerater is

	COMPONENT dphase_rom IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT sine_rom IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END COMPONENT;

type stat_type is (start,
				check_valid,
				get_freq,
				get_amp,
				get_phase,
				dphase_calc,
				dphase_calc_done,
				get_approximate_sine_l,
				get_approximate_sine_r,
				prepare_calc_sine,
				insert_value,
				amplify,
				calc_over,
				idle);
signal stat:stat_type:=idle;
signal sf,nsf:std_logic;

signal amp,phase:std_logic_vector(31 downto 0);
signal freq:std_logic_vector(7 downto 0);

signal dphase_rom_add:std_logic_vector(7 downto 0);
signal dphase:std_logic_vector(31 downto 0);

signal sine_rom_add:std_logic_vector(7 downto 0);
signal sine_rom_out:std_logic_vector(15 downto 0);

signal left_side:std_logic_vector(31 downto 0);
signal right_side:std_logic_vector(31 downto 0);

signal save_output:std_logic_vector(31 downto 0);

begin
	
	u1: dphase_rom port map(clock=>not clk,address=>dphase_rom_add,q=>dphase);
	u2: sine_rom port map(clock=>not clk,address=>sine_rom_add,q=>sine_rom_out);
	
	process (bigclk)
	begin
		if bigclk'event and bigclk='1' then
			sf<=not nsf;
		end if;
	end process;
	
	process (clk)
	variable insert_position:integer range 0 to 31;
	begin
		if clk'event and clk='1' then
			if sf=nsf then
				case stat is
					when start=>
						wren<='0';
						output<=(others=>'0');
						save_output<=(others=>'0');
						add_note<=address&"00";
						stat<=check_valid;
						
					when check_valid=>
						if out_note=0 then
							done<='1';
							stat<=idle;
						else
							add_note<=add_note+1;
							stat<=get_freq;
						end if;
					
					when get_freq=>
						freq<=out_note(7 downto 0);
						add_note<=add_note+1;
						stat<=get_amp;
					
					when get_amp=>
						amp<=out_note;
						add_note<=add_note+1;
						stat<=get_phase;
					
					when get_phase=>
						phase<=out_note;
						add_note<=add_note+1;
						stat<=dphase_calc;
					
					when dphase_calc=>
						dphase_rom_add<=freq;
						stat<=dphase_calc_done;
						
					when dphase_calc_done=>
						phase<=phase+dphase;
						stat<=get_approximate_sine_l;
						
					when get_approximate_sine_l=>
						sine_rom_add<=phase(31 downto 24);
						
						data_note<=phase;
						add_note<=add_note-1;
						wren<='1';
						
						stat<=get_approximate_sine_r;
						
					when get_approximate_sine_r=>
						wren<='0';
						left_side<=sine_rom_out&"0000000000000000";
						sine_rom_add<=sine_rom_add+1;
						stat<=prepare_calc_sine;
						
					when prepare_calc_sine=>
						right_side<=sine_rom_out&"0000000000000000";
						insert_position:=23;
						stat<=insert_value;
						
					when insert_value=>
						if phase(insert_position)='1' then
							left_side<=('0'&left_side(31 downto 1))+('0'&right_side(31 downto 1));
						else
							right_side<=('0'&left_side(31 downto 1))+('0'&right_side(31 downto 1));
						end if;
						
						if insert_position=0 then
							insert_position:=31;
							left_side<='0'&left_side(31 downto 1);
							stat<=amplify;
						else
							insert_position:=insert_position-1;
						end if;
						
					when amplify=>
						if amp(insert_position)='1' then
							save_output<=save_output+left_side;
						end if;
						
						if insert_position=24 then
							stat<=calc_over;
						else
							left_side<='0'&left_side(31 downto 1);
							insert_position:=insert_position-1;
						end if;
					
					when calc_over=>
						output<=save_output(31 downto 22);
						done<='1';
						stat<=idle;
						
					when others=>
						done<='0';
				end case;
			else
				nsf<=sf;
				stat<=start;
				done<='0';
			end if;
		end if;
	end process;
	
end;