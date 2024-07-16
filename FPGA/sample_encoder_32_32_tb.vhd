----------------------------------------------------------------------------------
--    Copyright (C) 2019 Dejan Priversek
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
-- Scopefun firmware: Sample encoder testbench
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

entity sample_encoder_32_32_tb is
end sample_encoder_32_32_tb;

architecture Behavioral of sample_encoder_32_32_tb is

	component sample_encoder_32_32
		Port (
			clk : in std_logic;
			wr_en : in std_logic;
			encoding_format: in std_logic_vector (3 downto 0);
			data_in : in std_logic_vector (31 downto 0);
			data_out : out std_logic_vector (31 downto 0);
			data_valid : out std_logic);
	end component;

	--Inputs
	signal clk              : std_logic := '0';
	signal wr_en            : std_logic := '0';
	signal encoding_format  : std_logic_vector(3 downto 0) := "1001";
	signal data_in		    : std_logic_vector(31 downto 0) := (others => '0');

	-- Outputs 
	signal data_out   : std_logic_vector(31 downto 0);
	signal data_valid : std_logic;
	
	-- Clock period definitions
	constant clk_wr_period : time := 4 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: sample_encoder_32_32
		port map (
			clk => clk,
			wr_en => wr_en,
			encoding_format => encoding_format,
			data_in => data_in,
			data_out => data_out,
			data_valid => data_valid
		);

	-- Clock process definitions
	clk_wr_period_proc :process
	begin
		clk <= '0';
		wait for clk_wr_period/2;
		clk <= '1';
		wait for clk_wr_period/2;
	end process;

	-- Generate data
	cnt_proc : process
		variable counter : unsigned (31 downto 0) := (others => '0');
	begin
		wait until falling_edge(clk);
		counter := counter + 1;
		data_in(31 downto 22) <= std_logic_vector(counter(9 downto 0));
		data_in(21 downto 12) <= std_logic_vector(counter(9 downto 0));
		data_in(11 downto 0)  <= std_logic_vector(counter(11 downto 0));
	end process;

	-- Write process
	wr_proc : process
	begin
		wr_en <= '0';
		for i in 1 to 10 loop
			wait until falling_edge(clk);
		end loop;
		for i in 1 to 100 loop
			wait until falling_edge(clk);
			wr_en <= '1';
		end loop;
		wait until falling_edge(clk);
		wr_en <= '0';

		wait;
	end process;


end Behavioral;
