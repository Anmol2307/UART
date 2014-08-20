----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:52:06 04/11/2013 
-- Design Name: 
-- Module Name:    frequencymodulator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity frequencymodulator is
	Generic ( ratio : integer := 16 );		--ratio = input frequency / output frequency
    Port ( in_clk : in  STD_LOGIC;			-- input clock signal
           out_clk : out  STD_LOGIC);		-- output clock signal
end frequencymodulator;

architecture Behavioral of frequencymodulator is
signal counter : integer := 0;				--the counter used to modulate the frequency
signal clk : std_logic := '0';				--temporary output clock signal
begin
	process(in_clk)
	begin
		if(rising_edge(in_clk)) then			--on rising edge of the input clock
			counter <= counter + 1;				--increasing the counter by 1
			if (counter = ratio/2 - 1  ) then	-- when counter reaches ratio/2 -1, we have done half clock cycle in modulated signal
			clk <= not clk;						-- we toggle the output clock signal
			counter <= 0;						-- reset the counter
			end if;
		end if;
	end process;
	out_clk <= clk ;							-- joining clk signal to output clock signal
end Behavioral;

