--------------------------------------------------------------------------------
-- Engineer: Klimann Wendelin
--
-- Create Date:   09:00:40 11/Okt/2013
-- Design Name:   parallel_to_i2s
-- Description:   
-- 
-- VHDL Test Bench for module: pcm3168
--
-- version: 00.01
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY pcm3168_tb_vhd IS
END pcm3168_tb_vhd;

ARCHITECTURE behavior OF pcm3168_tb_vhd IS 
	constant width       : integer := 24;
	constant clk_divider : integer :=  4;
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT pcm3168
	generic(
		width        : integer := width;
		clk_divider  : integer := clk_divider
);
	PORT(
	CLK         : in  std_logic;
	RESET       : in  std_logic;
	DIN_1       : in  std_logic;
	DOUT_1      : out std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL CLK    :  std_logic := '0';
	SIGNAL RESET  :  std_logic := '0';
	SIGNAL DIN_1  :  std_logic := '0';

	--Outputs
	SIGNAL DOUT_1   :  std_logic := '0';
  

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: pcm3168 
	PORT MAP(
		CLK 	      => CLK,
		RESET       => RESET,
		DOUT_1      => DOUT_1,
		DIN_1       => DIN_1
	);
	
	-- creates a reset signal at the start of the sequence 
	p_reset : process
	begin
		RESET <= '0';
		wait for 160 ns;
		RESET <= '1';
		-- Reset finished
		wait;
	end process	p_reset;
	
	-- generates the clock signal
	p_clk : process
	begin
		CLK <= '0';
		wait for 10 ns;
		CLK <= '1';
		wait for 10 ns;
	end process p_clk;
	
	-- provides the parallel input signal 
	p_din : process
	variable i      : POSITIVE :=1;
	variable first  : POSITIVE :=2;
	begin
	   if (first = 2) then 
			first := 1;
			DIN_1 <= '0';
			wait for 320 ns;
		end if;
		i := 1;
		while (i <= width) loop
			i := i + 1;
			DIN_1 <= '1';
			wait for 80 ns;
		end loop;
		i := 1;
		while (i <= width) loop
			i := i + 1;
			DIN_1 <= '0';
			wait for 80 ns;
			i := i + 1;
			DIN_1 <= '1';
			wait for 80 ns;
		end loop;
		i := 1;
		while (i <= width) loop
			i := i + 2;
			DIN_1 <= '0';
			wait for 160 ns;
			i := i + 2;
			DIN_1 <= '1';
			wait for 160 ns;
		end loop;
		i := 1;
		while (i <= width) loop
			i := i + 1;
			DIN_1 <= '0';
			wait for 80 ns;
		end loop;
	end process p_din; 

END;
