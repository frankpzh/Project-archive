---------------------------------------------------------------------------------------------
--实验题号   : ex3-3
--项目名称   : 十六位分频器
--文件名     : ff.vhd
--作者       : 潘震皓
--班号       : 计52
--创建日期   : 2007-04-12
--目标芯片   : EP1C6Q240C8
--电路模式   : 模式1
--时钟选择   : 时钟9
--演示说明   : 将clock9调整至3MHz，按动键1~4使数码管1~4均显示数字；此时扬声器发出声音即是被分频后的clock9，分频值为4个数码管显示的数字(16进制)
--功能描述   : 本文件是一个简单的触发器，作为组成计数器的最基本零件
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