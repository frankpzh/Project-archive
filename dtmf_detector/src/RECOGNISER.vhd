library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RECOGNISER is
	port (
		clk:in std_logic;
		sig1,sig2,sig3,sig4,sig5,sig6,sig7:in std_logic;
		--data_en:out std_logic;
		--data:out std_logic_vector(3 downto 0)
		data:out std_logic_vector(3 downto 0)
	);
end;

architecture main of RECOGNISER is
signal sig:std_logic_vector(6 downto 0);
signal counter:std_logic_vector(10 downto 0):=(others=>'0');
signal dataold,datareg:std_logic_vector(3 downto 0);
begin
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if datareg=dataold then
				if counter="11111111111" then
					data<=datareg;
				end if;
				counter<=counter+1;
			else
				dataold<=datareg;
				counter<=(others=>'0');
			end if;
		end if;
	end process;
	
	sig<=sig7&sig6&sig5&sig4&sig3&sig2&sig1;
	
	process(sig)
	begin
		case sig is
		when "0010001"=>
			datareg<="0001";
		when "0100001"=>
			datareg<="0010";
		when "1000001"=>
			datareg<="0011";
		when "0010010"=>
			datareg<="0100";
		when "0100010"=>
			datareg<="0101";
		when "1000010"=>
			datareg<="0110";
		when "0010100"=>
			datareg<="0111";
		when "0100100"=>
			datareg<="1000";
		when "1000100"=>
			datareg<="1001";
		when "0011000"=>
			datareg<="1010";
		when "0101000"=>
			datareg<="0000";
		when "1001000"=>
			datareg<="1011";
		when others=>
			datareg<="1111";
		end case;
	end process;
	
end;