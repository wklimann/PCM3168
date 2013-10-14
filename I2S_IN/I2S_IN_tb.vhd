--------------------------------------------------------------------------------
-- Engineer: Klimann Wendlin
--
-- Create Date:   07:25:11 11/Okt/2013
-- Design Name:   i2s_in_tb
-- Description:   
-- 
-- VHDL Test Bench for module: i2s_in
--
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY i2s_in_tb_vhd IS
END i2s_in_tb_vhd;

ARCHITECTURE behavior OF i2s_in_tb_vhd IS 
	constant width : integer := 24;
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT i2s_in
	generic(width : integer := width);
	PORT(
		LR_CLK       : IN std_logic;
		BIT_CLK      : IN std_logic;
		DIN          : IN std_logic;
		RESET        : IN std_logic;          
		DATA_L       : OUT std_logic_vector(width-1 downto 0);
		DATA_R       : OUT std_logic_vector(width-1 downto 0);
		DATA_RDY_L   : OUT std_logic;
		DATA_RDY_R   : OUT std_logic	
		);
	END COMPONENT;

	--Inputs
	SIGNAL LR_CLK   :  std_logic := '0';
	SIGNAL BIT_CLK  :  std_logic := '0';
	SIGNAL DIN      :  std_logic := '0';
	SIGNAL RESET    :  std_logic := '0';

	--Outputs
	SIGNAL DATA_L       :  std_logic_vector(width-1 downto 0);
	SIGNAL DATA_R       :  std_logic_vector(width-1 downto 0);
	SIGNAL DATA_RDY_L   :  std_logic;
	SIGNAL DATA_RDY_R   :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: i2s_in 
	PORT MAP(
		LR_CLK       => LR_CLK,
		BIT_CLK      => BIT_CLK,
		DIN          => DIN,
		RESET        => RESET,
		DATA_L       => DATA_L,
		DATA_R       => DATA_R,
		DATA_RDY_L   => DATA_RDY_L,
		DATA_RDY_R   => DATA_RDY_R
	);
	
	
	p_reset : process
	begin
		RESET <= '0';
		--LR_CK <= '1';
		wait for 640 ns;
		RESET <= '1';
		-- Reset finished
		wait;
	end process	p_reset;
	
	p_bit_clk : process
	begin
		BIT_CLK <= '0';
		wait for 10 ns;
		BIT_CLK <= '1';
		wait for 10 ns;
	end process p_bit_clk;
	
	p_lr_clk : process
	begin
		LR_CLK <= '0';
		wait for 480 ns;
		LR_CLK <= '1';
		wait for 480 ns;
	end process p_lr_clk;
	
	p_din : process
	variable i : POSITIVE :=1;
	begin
		i := 1;
		loop_1: while i <= 24 loop 
			DIN <= '0';
			wait for 20 ns;
			DIN <= '1';
			wait for 20 ns;
			i := i+1;
		end loop loop_1;
		i := 1;
		loop_2: while i <= 12 loop 
			DIN <= '0';
			wait for 40 ns;
			DIN <= '1';
			wait for 40 ns;
			i := i+1;
		end loop loop_2;
		i := 1;
		loop_3: while i <= 6 loop 
			DIN <= '0';
			wait for 80 ns;
			DIN <= '1';
			wait for 80 ns;
			i := i+1;
		end loop loop_3;
		
	end process p_din;

END;
