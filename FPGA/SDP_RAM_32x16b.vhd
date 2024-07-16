----------------------------------------------------------------------------------
--    Copyright (C) 2023 Dejan Priversek
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
-- Dual-Port RAM, Distributed, Read-First mode
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SDP_RAM_32x16b is
	Port (
		clk1  : in STD_LOGIC;
		clk2  : in STD_LOGIC;
		we    : in STD_LOGIC;
		addr1 : in STD_LOGIC_VECTOR (4 downto 0);
		addr2 : in STD_LOGIC_VECTOR (4 downto 0);
		di1   : in  STD_LOGIC_VECTOR (15 downto 0);
		do1   : out STD_LOGIC_VECTOR (15 downto 0);
		do2   : out STD_LOGIC_VECTOR (15 downto 0));
end SDP_RAM_32x16b;

architecture Behavioral of SDP_RAM_32x16b is

	constant DATA_DEPTH : integer := 32;
	constant DATA_WIDTH : integer := 16;

	type ram_type is array (DATA_DEPTH-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
	signal ram : ram_type;

	ATTRIBUTE ram_style: string;
	ATTRIBUTE ram_style OF ram: SIGNAL IS "distributed";

begin

	clk1_side:process (clk1)
	begin
		if (rising_edge(clk1)) then
			if (we = '1') then
				ram(to_integer(unsigned(addr1))) <= di1;
			end if;
			do1 <= ram(to_integer(unsigned(addr1)));
		end if;
	end process;

	clk2_side:process (clk2)
	begin
		if (rising_edge(clk2)) then
			do2 <= ram(to_integer(unsigned(addr2)));
		end if;
	end process;

end Behavioral;
