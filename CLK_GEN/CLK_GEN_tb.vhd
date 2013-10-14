--------------------------------------------------------------------------------
-- Engineer: Klimann Wendlin
--
-- Create Date:   07:25:11 11/Okt/2013
-- Design Name:   clk_gen_tb
-- Description:   
-- 
-- VHDL Test Bench for module: clk_gen
--
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY clk_gen_tb_vhd IS
END clk_gen_tb_vhd;

ARCHITECTURE behavior OF clk_gen_tb_vhd IS 
	constant width : integer := 24;
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT clk_gen
	generic(width : integer := width);
	PORT(
		CLK          : IN std_logic;
		RESET        : IN std_logic; 
		LR_CLK       : OUT std_logic;
		BIT_CLK      : OUT std_logic
);
	END COMPONENT;

	--Inputs
	SIGNAL CLK      :  std_logic := '0';
	SIGNAL RESET    :  std_logic := '0';

	--Outputs
	SIGNAL LR_CLK   :  std_logic := '0';
	SIGNAL BIT_CLK  :  std_logic := '0';

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: clk_gen 
	PORT MAP(
		CLK          => CLK,
		RESET        => RESET,
		LR_CLK       => LR_CLK,
		BIT_CLK      => BIT_CLK
);

	p_reset : process
	begin
		RESET <= '0';
		--LR_CK <= '1';
		wait for 100 ns;
		RESET <= '1';
		-- Reset finished
		wait;
	end process	p_reset;

	p_clk : process
	begin
		CLK <= '0';
		wait for 10 ns;
		CLK <= '1';
		wait for 10 ns;
	end process p_clk;

END;
