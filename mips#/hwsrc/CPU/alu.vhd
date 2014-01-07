library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu is
	port(
		A,B:in std_logic_vector(15 downto 0);
		sign:in std_logic_vector(3 downto 0);

		Loopback_dest:in std_logic_vector(1 downto 0);
		REG_last:in std_logic_vector(15 downto 0);
		
		rd:in std_logic_vector(2 downto 0);
		dest:out std_logic_vector(2 downto 0);
		Q:out std_logic_vector(15 downto 0);
		en_Q:out std_logic;
		
		C_old:in std_logic;
		C_new,C_cu:buffer std_logic
	);
end;

architecture main of alu is

signal C:unsigned(3 downto 0);
signal A_s,q3:signed(15 downto 0);
signal A_u,q1,q2:unsigned(15 downto 0);
signal A_real,B_real:std_logic_vector(15 downto 0);
signal q5,q6,q11,q12:std_logic_vector(16 downto 0);

begin
	
	A_real<=REG_last when Loopback_dest(0)='1' else A;
	B_real<=REG_last when Loopback_dest(1)='1' else B;
	
	dest<=rd;
	en_Q<='1' when sign<="1100" else '0';

	with sign select
	Q<=A_real						when "0000",
	   conv_std_logic_vector(q1,16)	when "0001",
	   conv_std_logic_vector(q2,16)	when "0010",
	   conv_std_logic_vector(q3,16)	when "0011",
	   (not A_real)+1				when "0100",
	   q5(15 downto 0)				when "0101",
	   q6(15 downto 0)				when "0110",
	   not A_real					when "0111",
	   A_real and B_real			when "1000",
	   A_real or B_real				when "1001",
	   A_real xor B_real			when "1010",
	   q11(15 downto 0)				when "1011",
	   q12(15 downto 0)				when "1100",
	   "0000000000000000"			when others;
	
	with sign select
	C_new<=q5(16)	when "0101",
			q6(16)	when "0110",
			q11(16)	when "1011",
			q12(16)	when "1100",
			'0'		when "1101",
			'1'		when "1110",
			C_old	when others;
	
	A_u<=unsigned(A_real);
	A_s<=signed(A_real);
	C<=unsigned(B_real(3 downto 0));
	q1<=shr(A_u,C);
	q2<=shl(A_u,C);
	q3<=shr(A_s,C);
	
	q5<=("0"&A_real)+("0"&B_real);
	q6<=("0"&A_real)-("0"&B_real);
	q11<=("0"&A_real)+("0"&B_real)+C_old;
	q12<=("0"&A_real)-("0"&B_real)-C_old;
	
	C_cu<=C_new;
	
end;