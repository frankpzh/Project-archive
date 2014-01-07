---------------------------------------------------------------------------------------------
--ʵ�����   : ex3-3
--��Ŀ����   : ʮ��λ��Ƶ��
--�ļ���     : ff.vhd
--����       : �����
--���       : ��52
--��������   : 2007-04-12
--Ŀ��оƬ   : EP1C6Q240C8
--��·ģʽ   : ģʽ1
--ʱ��ѡ��   : ʱ��9
--��ʾ˵��   : ��clock9������3MHz��������1~4ʹ�����1~4����ʾ���֣���ʱ�����������������Ǳ���Ƶ���clock9����ƵֵΪ4���������ʾ������(16����)
--��������   : ���ļ���һ���򵥵Ĵ���������Ϊ��ɼ���������������
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity syncff is
	port (
		D:in std_logic;
		last:in std_logic;
		clk:in std_logic;
		clr:in std_logic;
		Q:out std_logic
	);
end;

architecture main of syncff is
begin
	process (clk,clr)
	begin
		if clr='1' then
			Q<='0';
		else
			if clk'event and clk='1' then
				if last='1' then
					Q<=D;
				end if;
			end if;
		end if;
	end process;
end;