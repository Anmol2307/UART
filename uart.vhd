----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:23:16 04/11/2013 
-- Design Name: 
-- Module Name:    test_transmitter - Behavioral 
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

entity uart is
port (
	send : in STD_LOGIC := '0';           --Send input to the Transmitter. (SW0)
	input : in STD_logic_vector(6 downto 0);  --parallel input to the Transmitter.(7-bit : SW1-SW7)
	clk_in : in STD_LOGIC;                    --FPGA Clock of 19.2 Mhz to the Frequency Modulator.
	output : out STD_logic_vector(6 downto 0):= (others => '0');  --Output from the receiver.( 7-bit : LD1-LD7)
	reset : in STD_LOGIC := '0'    --reset to the Transmitter.(F5)
	);
end uart;

architecture Behavioral of uart is
    COMPONENT Transmitter
    PORT(
         send : IN  std_logic;
         input : IN  std_logic_vector(6 downto 0);
         clk_in : IN  std_logic;
         data_out : OUT  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;

	Component frequencymodulator 
	Generic ( ratio : integer := 16 );
	Port ( in_clk : in  STD_LOGIC;
		  out_clk : out  STD_LOGIC);
	end component;
	
	COMPONENT receiver
    PORT(
         line : IN  std_logic;
         clk_in : IN  std_logic;
         output : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
signal clk_fm_out : std_logic := '0';
signal clk_out : std_logic := '0';
signal line : std_logic;
begin

tm: Transmitter PORT MAP (
          send => send,
          input => input,
          clk_in => clk_fm_out,
          data_out => line,
          reset => reset
        );
fm_uart: frequencymodulator generic map (ratio => 16)
			Port map (
			in_clk => clk_out,
			out_clk => clk_fm_out
			);
fm_clk: frequencymodulator generic map (ratio => 100)
			Port map (
			in_clk => clk_in,
			out_clk => clk_out
			);
			
rm: receiver PORT MAP (
          line => line,
          clk_in => clk_out,
          output => output
        );
			
end Behavioral;

 
