---------------------------------------------------------------------------------
-- Engineer:      Klimann Wendelin
--
-- Create Date:   08:36:20 11/Okt/2013
-- Design Name:   i2s_out
--
-- Description:   
-- 
-- This module provides a bridge between an I2S serial device (audio ADC, S/PDIF 
-- Decoded data) and a parallel device (microcontroller, IP block).
--
-- It's coded as a generic VHDL entity, so developer can choose the proper signal
-- width (8/16/24/32 bit)
--
-- Input takes:
-- -I2S Bit Clock
-- -I2S LR Clock (Left/Right channel indication)
-- -DATA_L / DATA_R parallel inputs
--
-- Output provides:
-- -I2S Data
-- -DATA_RDY output ready signals.
-- 
--
-- The data from the parallel inputs is shifted to the I2S data output
--
--------------------------------------------------------------------------------
-- I2S Waveform summary
--
-- BIT_CK     __    __   __    __    __            __    __    __    __   
--           | 1|__| 2|_| 3|__| 4|__| 5|__... ... |32|__| 1|__| 2|__| 3| ...
--
-- LR_CK                                  ... ...     ___________________
--           ____________L_Channel_Data______________|   R Channel Data ...
--
-- DATA      x< 00 ><D24><D22><D21><D20>  ... ...     < 00 ><D24><D23>  ...
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity i2s_out is 
-- width: How many bits (from MSB) are gathered from the serial I2S input
generic(width : integer := 24);

port(
	--  I2S ports
	LR_CLK    : in  std_logic;      --Left/Right indicator clock
	BIT_CLK   : in  std_logic;      --Bit clock
	DOUT      : out std_logic;      --Data Output
	
	-- Control ports
	RESET     : in  std_logic;      --Asynchronous Reset (Active Low)
	
	-- Parallel ports 
	-- use (width-1 downto 0); for big endian fotmat 
	-- or (0 to width-1) for little endian
	DATA_L    : in std_logic_vector(0 to width-1);
	DATA_R    : in std_logic_vector(0 to width-1);
	
	-- Output status ports
	DATA_RDY_L    : out std_logic;      --Falling edge means data is ready
	DATA_RDY_R    : out std_logic       --Falling edge means data is ready
);
end i2s_out;


architecture rtl of i2s_out is

	--signals 
	signal counter           : integer range 0 to width;
	signal s_current_lr      : std_logic;
		
begin
   
	-- serial to parallel interface
	i2s_out: process(RESET, BIT_CLK, LR_CLK, DATA_L, DATA_R)
	begin
		if(RESET = '0') then
			
			counter          <=  0;
			s_current_lr     <= '0';
			DATA_RDY_L       <= '0';
			DATA_RDY_R       <= '0';
			DOUT             <= '0';

		elsif(BIT_CLK'event and BIT_CLK = '0') then
		
			if(s_current_lr = LR_CLK) then
				
				if(s_current_lr = '1') then
					DOUT <= DATA_R(counter);
				else 
					DOUT <= DATA_L(counter);
				end if;
				
				if(counter < width-1) then
					counter <= counter + 1;
				else
					-- if there is a failure in the clk signals rate -> send 0 to DOUT
					DOUT <= '0';
				end if;
				-- reset the DATA_RDY_x signals 
				DATA_RDY_L <= '0';
				DATA_RDY_R <= '0';
			
			-- if there is a change in the LR_CLK signal enter the else branch
			else
			
				if(s_current_lr = '1') then
					DOUT <= DATA_R(counter);
					DATA_RDY_R <= '1';
				else 
					DOUT <= DATA_L(counter);
					DATA_RDY_L <= '1';
				end if;
				counter <= 0;
				s_current_lr <= LR_CLK;
				
			end if; -- (s_current_lr = LR_CLK)
		end if; -- reset / rising_edge
	end process i2s_out;

end rtl;
