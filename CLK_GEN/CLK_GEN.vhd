---------------------------------------------------------------------------------
-- Engineer:      Klimann Wendelin
--
-- Create Date:   07:25:11 11/Okt/2013
-- Design Name:   clk_gen
--
-- Description:   
-- 
-- This module is a simple clock divider which generates the BIT_CLK and the LR_CLK
-- signals for the I2S interfaces.
--
-- It's coded as a generic VHDL entity, so developer can choose the proper signal
-- width (8/16/24/32 bit) -> x BIT_CLK cycles per one LR_CLK cycle 
--
-- Input takes:
-- -CLK    - system clock 
-- -Reset  - system reset
--
-- Output provides:
-- -BIT_CLK - bit clock output
-- -LR_CLK  - left/right selection -> 0 = left and 1 = right.
--          
-- 
--------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity clk_gen is 
-- width: How many bits (from MSB) are gathered from the serial I2S input
generic(
		width       : integer := 24;
		clk_divider : integer :=  4  -- a multiple of 2
);
port(
	--  Input ports
	CLK        : in std_logic;       --System clock

	-- Control ports
	RESET      : in std_logic;       --Asynchronous Reset (Active Low)

	-- Output ports
	BIT_CLK    : out std_logic;      --Bit Clock
	LR_CLK     : out std_logic       --Left/Right Clock
);
end clk_gen;

architecture rtl of clk_gen is

	--signals 
	signal s_counter_bit       : integer range 0 to clk_divider;
	signal s_counter_lr        : integer range 0 to width;
	signal s_bit_clk           : std_logic;
	signal s_lr_clk            : std_logic;

begin

--------------------------------------------------------------------------------
-- generates the BIT_CLK clock 
--------------------------------------------------------------------------------
	p_bit_clk: process(RESET, CLK)
		variable v_lr_clk_enable : std_logic;
	begin
		if(RESET = '0') then

			BIT_CLK          <= '0';
			LR_CLK           <= '0';

			s_counter_bit    <=  0 ;
			s_counter_lr     <=  0 ; 
			s_bit_clk        <= '0';
			s_lr_clk         <= '1';

			v_lr_clk_enable  := '0';

		elsif(CLK'event and CLK = '1') then

			if(s_counter_bit < (clk_divider-1)/2) then 
				s_counter_bit <= s_counter_bit + 1;
			else 
				s_bit_clk <= not s_bit_clk;
				s_counter_bit <= 0;
				if(s_bit_clk = '1') then
					v_lr_clk_enable := '1';
				end if;
			end if;

			if(v_lr_clk_enable = '1') then
				if(s_counter_lr = 0) then 
					s_lr_clk <= not s_lr_clk;
					s_counter_lr <= s_counter_lr + 1;
				elsif(s_counter_lr = width-1) then
					s_counter_lr <= 0;
				else
					s_counter_lr <= s_counter_lr + 1;
				end if;
			v_lr_clk_enable := '0';
			end if;

		end if; -- reset / rising_edge
		BIT_CLK <= s_bit_clk;
		LR_CLK  <= s_lr_clk;
	end process p_bit_clk;

end rtl;
