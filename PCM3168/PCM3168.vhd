---------------------------------------------------------------------------------
-- Engineer:      Klimann Wendelin
--
-- Create Date:   07:25:11 11/Okt/2013
-- Design Name:   pcm3168
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

entity pcm3168 is 
generic(
	-- width: How many bits (from MSB) are gathered from the serial I2S input
	width        : integer := 24;
	-- sclk_divider: divides the system clock and has to be a multiple of 2
	sclk_divider : integer := 4;  
	-- clk_divider: divides the system clock and has to be a multiple of 2
	clk_divider  : integer := 4 
);
port(
	--  I2S ports
	DIN_1       : in  std_logic;      --Data Input
	DOUT_1      : out std_logic;      --Date Output
	LR_CLK      : out std_logic;      --Left/Right indicator clock
	BIT_CLK     : out std_logic;      --Bit clock
	-- Control ports
	CLK         : in  std_logic;       --System Clock
	RESET       : in  std_logic;       --Asynchronous Reset (Active High)
	SCLK        : out std_logic        --System Clock for the PCM3168 Audio Codec
);
end pcm3168;


architecture structural of pcm3168 is

	--signals 
	signal s_data_l     : std_logic_vector(width-1 downto 0);
	signal s_data_r     : std_logic_vector(width-1 downto 0);
	signal s_lr_clk     : std_logic;
	signal s_bit_clk    : std_logic;
	signal s_sclk       : std_logic;

	component i2s_in is
		generic(
			width        : integer
);
		port(
			LR_CLK       : in  std_logic;      --Left/Right indicator clock
			BIT_CLK      : in  std_logic;      --Bit clock
			DIN          : in  std_logic;      --Data Input
			RESET        : in  std_logic;      --Asynchronous Reset (Active Low)
			DATA_L       : out std_logic_vector(width-1 downto 0);
			DATA_R       : out std_logic_vector(width-1 downto 0);
			DATA_RDY_L   : out std_logic;     --Falling edge means data is ready
			DATA_RDY_R   : out std_logic      --Falling edge means data is ready
);
	end component i2s_in;

	component i2s_out is
		generic(
			width        : integer
);
		port(
			LR_CLK       : in  std_logic;      --Left/Right indicator clock
			BIT_CLK      : in  std_logic;      --Bit clock
			DOUT         : out std_logic;      --Data Output
			RESET        : in  std_logic;      --Asynchronous Reset (Active Low)
			DATA_L       : in std_logic_vector(0 to width-1);
			DATA_R       : in std_logic_vector(0 to width-1);
			DATA_RDY_L   : out std_logic;      --Falling edge means data is ready
			DATA_RDY_R   : out std_logic       --Falling edge means data is ready
);
	end component i2s_out;

	component clk_gen is
		generic(
			width        : integer;
			clk_divider  : integer
);
		port(
			CLK          : in std_logic;       --System clock
			RESET        : in std_logic;       --Asynchronous Reset (Active Low)
			BIT_CLK      : out std_logic;      --Bit Clock
			LR_CLK       : out std_logic       --Left/Right Clock
);
	end component clk_gen;
	
	component sclk_gen is
		generic(
			sclk_divider : integer
);
		port(
			CLK          : in std_logic;       --System clock
			RESET        : in std_logic;       --Asynchronous Reset (Active Low)
			SCLK         : out std_logic       --PCM3168 System Clock
);
	end component sclk_gen;
		
begin

BIT_CLK   <= s_bit_clk;
LR_CLK    <= s_lr_clk;
SCLK      <= s_sclk;
--s_data_l  <= (others => '0');
--s_data_r  <= (others => '1');

SCLK_PCM3168: sclk_gen 
				generic map(
						sclk_divider  =>  sclk_divider
)
				port map(
						CLK        =>  CLK,
						RESET      =>  RESET,
						SCLK       =>  s_sclk
);

CLK_96k: clk_gen 
				generic map(
						width => width,
						clk_divider  =>  clk_divider
)
				port map(
						CLK        =>  s_sclk,
						RESET      =>  RESET,
						BIT_CLK    =>  s_bit_clk,
						LR_CLK     =>  s_lr_clk
);

I2S_IN_1: i2s_in 
				generic map(
						width => width
)
				port map(
						RESET       =>  RESET,
						DIN         =>  DIN_1,
						BIT_CLK     =>  s_bit_clk,
						LR_CLK      =>  s_lr_clk,
						DATA_L      =>  s_data_l,
						DATA_R      =>  s_data_r,
						DATA_RDY_L  =>  open,
						DATA_RDY_R  =>  open
);

I2S_OUT_1: i2s_out 
				generic map(
						width => width
)
				port map(
						RESET       =>  RESET,
						DOUT        =>  DOUT_1,
						BIT_CLK     =>  s_bit_clk,
						LR_CLK      =>  s_lr_clk,
						DATA_L      =>  s_data_l,
						DATA_R      =>  s_data_r,
						DATA_RDY_L  =>  open,
						DATA_RDY_R  =>  open
);

end architecture structural;
