----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:45:36 04/11/2013 
-- Design Name: 
-- Module Name:    receiver - Behavioral 
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

entity receiver is
    Port ( line : in  STD_LOGIC;								-- the input data line
			  clk_in : in std_logic;							-- the clock working at 16f
			  output : out std_logic_vector(6 downto 0) );		-- the parallel output of the 7 bit signal ( that is  received sequentially)
end receiver;

architecture Behavioral of receiver is
type state_type is (idle,receiver_active,data_storage,data_received);  --names of states of the receiver
signal current_s: state_type;  									--current state declaration.
signal count : integer := 0;									-- the counter used to count the number of bits received so far
signal mod7count : integer := 0;								-- Counter used to reach the center of start bit 
signal mod15count : integer := 0;								-- Counter used to move from center of one bit to the center of next bit
begin
process(clk_in)
	begin
		if(rising_edge(clk_in)) then							-- on rising edge of the input clock, we take actions according to current state and then update the current state
			case current_s is								
				when idle =>									-- when in idle state
					if (line = '1') then							-- if data input is 1 that is signal transmission has not started
						current_s <= idle;								--saty in idle state
					elsif(line = '0') then 							--if data input is 0 that is start bit has come and hence the transmission has started
						current_s <= receiver_active;			-- move the control to receiver active state
					end if;
				when receiver_active	=>						--when in receiver active state
					--mod7counter is used to keep track of the current location over the start bit. when this bit reaches 7, we have reached the center of start bit.				
					if( mod7count /= 7) then 						--if mod7count has not reached 7
						current_s <= receiver_active;					--we are stil on start bit,stay in receiver active state
						mod7count <= mod7count + 1;						--so we move a step ahead on the stop bit
					else											-- when md7count reaches 7
						current_s <= data_storage;						--we are to now start storing the data, so we move to data_storage state
						mod7count <= 0;									--mod7count is now reset to 0 
					end if;
				when data_storage =>							--when in data storage state, we have to watch for 2 counters, mod15count for center of next bit and count for number of bits received
					if ( count /= 7 and mod15count /= 15 ) then	--	when none of the counter has overflown
						current_s <= data_storage;					--we stay in the same state,looking for center of current bit
						mod15count <= mod15count + 1;				--and increment the counter concerned
					elsif (count /= 7) then						-- when mod15count has overflown,we have received a bit
						current_s <= data_storage;					-- we stay in the same state, now looking for center of next bit
						output(count) <= line;						--assign the bit received to output signal
						count <= count +1;							--increment number of bits received
						mod15count <= 0;							--reset the counter		
					else										--when both the counter overflow,we have reached end of data,waiting for stop bit
						current_s <= data_received;					--we have received the data, moving to data_received state
						count <= 0;									-- resetting the count to 0	
						mod15count <= 0;							-- resetting the mod15count to 0	
						mod7count <= 0;								-- resetting the mod7count to 0	
					end if;			
				when data_received =>							--when in data received state, we are looking for stop bit
					if (mod15count /= 15) then						-- when not yet at center of stop bit
						current_s <= data_received;						--keep waiting for it, stay in same state
						mod15count <= mod15count + 1;					--incrementing the counter
					else											--when mod15cont overflows, we are at center of stop bit
						current_s <= idle;								--so now moving back to idle state
						mod15count <= 0;								--resetting the mod15count
					end if;
			end case;		
		end if;
	end process;

end Behavioral;

