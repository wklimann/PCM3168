---------------------------------------------------------------------------------
-- Engineer:      Klimann Wendelin
--
-- Create Date:   10:12:13 20/Okt/2013
-- Design Name:   clk_gen
--
-- Description:   
-- 
-- This module is a simple clock divider which generates the SCLK signal for the 
-- PCM3168 audio interfaces.
--
--
-- Input takes:
-- -CLK    - system clock 
-- -Reset  - system reset
--
-- Output provides:
-- -SCLK - PCM3168 clock output
--          
-- 
--------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity sclk_gen is 
generic(
		sclk_divider : integer := 4  -- a multiple of 2
		  );

port(
	--  Input ports
	CLK        : in std_logic;       --System clock
	-- Control ports
	RESET      : in std_logic;       --Asynchronous Reset (Active High)
	-- Output ports
	SCLK    : out std_logic          --PCM3168 system clock
);
end sclk_gen;


architecture rtl of sclk_gen is

	--signals 
	signal s_counter_bit       : integer range 0 to sclk_divider;
	signal s_sclk              : std_logic;

begin

--------------------------------------------------------------------------------
-- generates the BIT_CLK clock 
--------------------------------------------------------------------------------
	p_sclk: process(RESET, CLK)
	begin
		if(RESET = '1') then
		
			SCLK           <= '0';
			s_counter_bit  <=  0 ;
			s_sclk         <= '0';
			
		elsif (CLK'event and CLK = '1') then

			if (s_counter_bit < (sclk_divider-1)/2) then 
				s_counter_bit <= s_counter_bit + 1;
			else 
				s_sclk <= not s_sclk;
				s_counter_bit <= 0;
			end if;
				
		end if; -- reset / rising_edge
		SCLK <= s_sclk;
	end process p_sclk;

end rtl;
