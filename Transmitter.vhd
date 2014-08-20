----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:05:58 04/11/2013 
-- Design Name: 
-- Module Name:    Transmitter - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Transmitter is
port (
	send : in STD_LOGIC := '0';  --High input signal to start Transmission of data.
	input : in STD_logic_vector(6 downto 0); --7-bit data received parallel to the Transmitter.
	clk_in : in STD_LOGIC; --Clock Input to Transmitter. Baud rate at 19.2 Khz.
	data_out : out std_logic := '1';   --Output line of the Transmitter. Connected to Receiver module.
	reset : in STD_LOGIC := '0' --Resets the Transmitter to idle state.
	);
end Transmitter;



 architecture Behavioral of Transmitter is
type state_type is (idle,start_transmission,data_transmission,data_sent);  --type of state machine.
signal current_s,next_s: state_type;  --current and next state declaration.
signal count : integer := 0;
begin
-- Process Dependencies at the rising edge of the clock.(The machine changes state at this juncture.)
	process(clk_in)
	begin
	--Rising edge of the clock.
		if(rising_edge(clk_in)) then
		--Determining the next state and output.
			case current_s is
				when idle =>
				-- If reset is set 1 at this stage then it will remain in the same state 
				--without starting the transmission.
						
					if (reset = '1') then
						current_s <= idle;
						data_out <= '1';
				--If send = '1', start transmission. 
				--In this state, the start bit '0' is sent.
					elsif(send = '1') then 
						current_s <= start_transmission;
						data_out <= '0';
					else
				--Else remain in idle state.	
						next_s <= idle;
					end if;
				-- If we are in the start_transmission state 
				when start_transmission	=>
				--Start bit has been sent on the line.
				--then we start transmitting the data and enter the data transmission state 
					current_s <= data_transmission;
					data_out <= input(count);  --Sending First bit of data on the line.
					count <= count + 1;  --Count of bits sent is incremented.
				
				-- If we have started transmitting the data	
				when data_transmission =>
				--If count not reached to 7(all bits not transmitted)
				--then continue transmitting the data and remain in the same state i.e data transmission.
					if ( count /= 7 ) then
						current_s <= data_transmission; 
						data_out <= input(count);  --Transmit next bit.
						count <= count + 1;        --Count of bits sent is incremented.
						
					-- this means we have transmitted all the 8 bits so enter the data_sent state
					elsif (count = 7) then
						current_s <= data_sent;
						count <= 0;    -- Count is reset is 0.
						data_out <= '1';  -- Line is inactive.Stop bit sent.
					end if;	
					
				 -- If we have finished transmitting the data	
				when data_sent =>
				 -- If reset is set 1 the state is again made idle for further transmission.
					if( reset = '1') then
						current_s <= idle;
						data_out<='1';
					else
					--Remain in data_sent state.
						current_s <= data_sent;
						data_out<='1';
					end if;
						
			end case;		
		end if;
	end process;
end Behavioral;

