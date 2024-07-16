----------------------------------------------------------------------------------
--    Copyright (C) 2024 Dejan Priversek
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------

--
-- Scopefun firmware: Digital pattern generator testbench
--

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dig_pattern_gen_tb is
end dig_pattern_gen_tb;

architecture Behavioral of dig_pattern_gen_tb is

	component dig_pattern_gen
		generic (
			DIG_MAX_SAMPLES : integer := 1024);
		Port (
			clk_in : in  STD_LOGIC;
			digitalPatternOutputEn : in  STD_LOGIC;
			digitalPatternOutputMode : in STD_LOGIC;
			digitalPatternOutputRestart : in  STD_LOGIC;
			digitalClkDivide : in STD_LOGIC_VECTOR (31 downto 0);
			data_in   : in  STD_LOGIC_VECTOR (11 downto 0);
			data_out  : out STD_LOGIC_VECTOR (11 downto 0);
			addrb_dig : out STD_LOGIC_VECTOR (14 downto 0));
	end component;

	CONSTANT DIG_MAX_SAMPLES : integer := 1024; -- custom digital signal memory depth
	
	--Inputs
	signal clk_in                      : std_logic := '0';
	signal digitalPatternOutputEn      : std_logic := '0';
	signal digitalPatternOutputMode    : std_logic := '0';
	signal digitalPatternOutputRestart : std_logic := '0';
	signal digitalClkDivide    : std_logic_vector(31 downto 0) := (others => '0');
	signal data_in		       : std_logic_vector(11 downto 0) := (others => '0');

	-- Outputs 
	signal data_out   : std_logic_vector(11 downto 0) := (others => '0');
	signal addrb_dig  : std_logic_vector(14 downto 0) := (others => '0');
	
	-- Clock period definitions
	constant clk_wr_period : time := 4 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: dig_pattern_gen
		generic map (
			DIG_MAX_SAMPLES => DIG_MAX_SAMPLES)
		port map(
			clk_in => clk_in,
			digitalPatternOutputEn => digitalPatternOutputEn,
			digitalPatternOutputMode => digitalPatternOutputMode,
			digitalPatternOutputRestart => digitalPatternOutputRestart,
			digitalClkDivide => digitalClkDivide,
			data_in => data_in,
			data_out => data_out,
			addrb_dig => addrb_dig
		);

	-- Clock process definitions
	clk_wr_period_proc :process
	begin
		clk_in <= '0';
		wait for clk_wr_period/2;
		clk_in <= '1';
		wait for clk_wr_period/2;
	end process;

	-- Generate data
	cnt_proc : process
		variable counter : unsigned (11 downto 0) := (others => '0');
	begin
		wait until addrb_dig'event;
		counter := counter + 1;
		wait until rising_edge(clk_in);
		data_in <= std_logic_vector(addrb_dig(11 downto 0)); -- dummy data
	end process;

	-- Test digital pattern generation process
	wr_proc : process
	begin
		for i in 1 to 10 loop
			wait until falling_edge(clk_in);
			--digitalPatternOutputEn <= '0';
		end loop;
		wait until falling_edge(clk_in);
		digitalPatternOutputMode <= '1'; -- single burst
		for i in 1 to 10 loop
			wait until falling_edge(clk_in);
			digitalPatternOutputEn <= '1';
		end loop;
		for i in 1 to 1200 loop
			wait until falling_edge(clk_in);
			--digitalPatternOutputEn <= '0';
		end loop;
		wait until falling_edge(clk_in);
		for i in 1 to 30 loop
			wait until falling_edge(clk_in);
			digitalPatternOutputRestart <= '1'; -- restart pattern
		end loop;
		wait until falling_edge(clk_in);
		digitalPatternOutputRestart <= '0';			
		wait until falling_edge(clk_in);
		for i in 1 to 500 loop
			wait until falling_edge(clk_in);
		end loop;
		for i in 1 to 2000 loop
			wait until falling_edge(clk_in);
			digitalPatternOutputEn <= '1';
		end loop;
		for i in 1 to 30 loop
			wait until falling_edge(clk_in);
			digitalPatternOutputRestart <= '1'; -- restart pattern
		end loop;
		wait until falling_edge(clk_in);
		digitalPatternOutputRestart <= '0';	
		digitalPatternOutputMode <= '0'; -- loop pattern
		for i in 1 to 2000 loop
			wait until falling_edge(clk_in);
			digitalPatternOutputEn <= '1';
		end loop;
		wait;
	end process;


end Behavioral;
