--------------------------------------------------------------------------------
-- Engineer: Klimann Wendelin
--
-- Create Date:   09:00:40 11/Okt/2013
-- Design Name:   parallel_to_i2s
-- Description:   
-- 
-- VHDL Test Bench for module: i2s_out
--
-- version: 00.01
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY i2s_out_tb_vhd IS
END i2s_out_tb_vhd;

ARCHITECTURE behavior OF i2s_out_tb_vhd IS 
	constant width : integer := 24;
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT i2s_out
	generic(width : integer := width);
	PORT(
		LR_CLK      : IN std_logic;
		BIT_CLK     : IN std_logic;
		DOUT        : OUT std_logic;
		RESET       : IN std_logic;          
		DATA_L      : IN std_logic_vector(width-1 downto 0);
		DATA_R      : IN std_logic_vector(width-1 downto 0);
		DATA_RDY_L  : OUT std_logic;
      DATA_RDY_R  : OUT std_logic		
		);
	END COMPONENT;

	--Inputs
	SIGNAL LR_CLK   :  std_logic := '0';
	SIGNAL BIT_CLK  :  std_logic := '0';
	SIGNAL DOUT     :  std_logic := '0';
	SIGNAL RESET    :  std_logic := '0';

	--Outputs
	SIGNAL DATA_L      :  std_logic_vector(width-1 downto 0);
	SIGNAL DATA_R      :  std_logic_vector(width-1 downto 0);
	SIGNAL DATA_RDY_L  :  std_logic;
	SIGNAL DATA_RDY_R  :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: i2s_out 
	PORT MAP(
		LR_CLK      => LR_CLK,
		BIT_CLK     => BIT_CLK,
		DOUT        => DOUT,
		RESET       => RESET,
		DATA_L      => DATA_L,
		DATA_R      => DATA_R,
		DATA_RDY_L  => DATA_RDY_L,
		DATA_RDY_R  => DATA_RDY_R
	);
	
	-- creates a reset signal at the start of the sequence 
	p_reset : process
	begin
		RESET <= '0';
		--LR_CK <= '1';
		wait for 640 ns;
		RESET <= '1';
		-- Reset finished
		wait;
	end process	p_reset;
	
	-- generates the bit clock signal
	p_bit_clk : process
	begin
		BIT_CLK <= '0';
		wait for 10 ns;
		BIT_CLK <= '1';
		wait for 10 ns;
	end process p_bit_clk;
	
	-- generates the LR clock signal 
   p_lr_clk : process
	begin
		LR_CLK <= '0';
		wait for 480 ns;
		LR_CLK <= '1';
		wait for 480 ns;
	end process p_lr_clk;
	
	-- provides the parallel input signal 
	p_dout : process
	variable i : POSITIVE :=1;
	begin
		wait for 20 ns;
		DATA_L <= "111111111111111111111111";
		DATA_R <= "111111111111111111111111";
		wait for 480 ns;
		DATA_L <= "001100000000000000000000";
		DATA_R <= "001100000000000000000000";
		wait for 480 ns;
		DATA_L <= "110011001100110011001100";
		DATA_R <= "110011001100110011001100";
		wait for 480 ns;
		DATA_L <= "101010101010101010101010";
		DATA_R <= "101010101010101010101010";
		wait for 480 ns;
		DATA_L <= "110011001100110011001100";
		DATA_R <= "110011001100110011001100";
		wait for 480 ns;
		DATA_L <= "110011000000000000000011";
		DATA_R <= "110011000000000000000011";
		wait for 480 ns;
		DATA_L <= "001100000000000000000000";
		DATA_R <= "001100000000000000000000";
		wait for 480 ns;
		DATA_L <= "111111111111111111111111";
		DATA_R <= "111111111111111111111111";
		wait for 480 ns;
		DATA_L <= "001100000000000000000000";
		DATA_R <= "001100000000000000000000";
		wait for 480 ns;
		DATA_L <= "110011001100110011001100";
		DATA_R <= "110011001100110011001100";
		wait for 480 ns;
		DATA_L <= "101010101010101010101010";
		DATA_R <= "101010101010101010101010";
		wait for 480 ns;
		DATA_L <= "110011001100110011001100";
		DATA_R <= "110011001100110011001100";
		wait for 480 ns;
		DATA_L <= "110011000000000000000011";
		DATA_R <= "110011000000000000000011";
		wait for 480 ns;
		DATA_L <= "001100000000000000000000";
		DATA_R <= "001100000000000000000000";
		wait for 480 ns;
	end process p_dout;

END;
