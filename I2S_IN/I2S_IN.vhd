---------------------------------------------------------------------------------
-- Engineer:      Klimann Wendelin 
--
-- Create Date:   07:25:11 11/Okt/2013
-- Design Name:   i2s_in
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
-- -I2S Data
-- -I2S Bit Clock
-- -I2S LR Clock (Left/Right channel indication)
--
-- Output provides:
-- -DATA_L / DATA_R parallel inputs
-- -DATA_RDY_L / DATA_RDY_R output ready signals.
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

entity i2s_in is 
-- width: How many bits (from MSB) are gathered from the serial I2S input
generic(width : integer := 24);

port(
	--  I2S ports
	LR_CLK    : in  std_logic;      --Left/Right indicator clock
	BIT_CLK   : in  std_logic;      --Bit clock
	DIN       : in  std_logic;      --Data Input
	
	-- Control ports
	RESET     : in  std_logic;      --Asynchronous Reset (Active Low)
	
	-- Parallel ports
	DATA_L    : out std_logic_vector(width-1 downto 0);
	DATA_R    : out std_logic_vector(width-1 downto 0);
	
	-- Output status ports
	DATA_RDY_L    : out std_logic;     --Falling edge means data is ready
	DATA_RDY_R    : out std_logic      --Falling edge means data is ready
);
end i2s_in;


architecture rtl of i2s_in is

	--signals 
	signal shift_reg         : std_logic_vector(width-1 downto 0);
	signal s_parallel_load   : std_logic;
	signal s_current_lr      : std_logic;
		
begin

	-- serial to parallel interface
	i2s_in: process(RESET, BIT_CLK, LR_CLK, DIN)
	begin
		if(RESET = '0') then
		
			DATA_L     <= (others => '0');
			DATA_R     <= (others => '0');
			shift_reg  <= (others => '0');
			
			s_current_lr     <= '0';
			s_parallel_load  <= '0';
			DATA_RDY_L       <= '0';
			DATA_RDY_R       <= '0';
			
		elsif(BIT_CLK'event and BIT_CLK = '1') then
		
			if(s_current_lr = LR_CLK) then
				-- Push data into the shift register
				shift_reg(width-1 downto 1) <= shift_reg(width-2 downto 0);
				shift_reg(0) <= DIN;	
				if (s_parallel_load = '1') then
					if(s_current_lr = '0') then
						--Output Right Channel
						DATA_R <= shift_reg;
					else
						--Output Left Channel
						DATA_L <= shift_reg;
					end if;
					s_parallel_load <= '0';
					DATA_RDY_L <= '0'; 
					DATA_RDY_R <= '0'; 
				end if;
			else
				-- Push data into the shift register
				shift_reg(width-1 downto 1) <= shift_reg(width-2 downto 0);
				shift_reg(0) <= DIN;	
				-- setup for parallel register load 
				s_parallel_load <= '1';
				if (s_current_lr = '1') then
					DATA_RDY_R <= '1';
				else
					DATA_RDY_L <= '1';
				end if;
				s_current_lr <= LR_CLK;
				
			end if;
		end if; -- reset / rising_edge
	end process i2s_in;
	
end rtl;