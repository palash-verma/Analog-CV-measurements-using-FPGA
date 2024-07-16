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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity sample_encoder_32_32 is
	Port (
		clk : in std_logic;
		wr_en : in std_logic;
		encoding_format: in std_logic_vector (3 downto 0);
		data_in : in std_logic_vector (31 downto 0);
		data_out : out std_logic_vector (31 downto 0);
		data_valid : out std_logic);
end sample_encoder_32_32;

architecture Behavioral of sample_encoder_32_32 is

	signal data_tmp: std_logic_vector (31 downto 0);
	signal valid_tmp: std_logic;
	signal data_sel: std_logic := '0';

begin

	data_valid <= valid_tmp;
	data_out <= data_tmp;

	generate_clk_enable: process(clk)

	begin

		if rising_edge(clk) then

			case encoding_format (3 downto 0) is

				when "1111" => -- all channels
					data_tmp <= data_in;
					valid_tmp <= wr_en;

				when "1010" => -- 10: select CH1 and Digital D11 to D6
					if wr_en = '1' then
						if data_sel = '0' then
							data_sel <= '1';
							valid_tmp <= '0';
							data_tmp(31 downto 22) <= data_in(31 downto 22);
							data_tmp(21 downto 16) <= data_in(11 downto 6);
						else
							data_sel <= '0';
							valid_tmp <= '1';
							data_tmp(15 downto 6) <= data_in(31 downto 22);
							data_tmp(5 downto 0)  <= data_in(11 downto 6);
						end if;
					else
						valid_tmp <= '0';
						data_sel <= '0';
					end if;

				when "1001" => -- 9: select CH1 and Digital D5 to D0
					if wr_en = '1' then
						if data_sel = '0' then
							data_sel <= '1';
							valid_tmp <= '0';
							data_tmp(31 downto 22) <= data_in(31 downto 22);
							data_tmp(21 downto 16) <= data_in(5 downto 0);
						else
							data_sel <= '0';
							valid_tmp <= '1';
							data_tmp(15 downto 6) <= data_in(31 downto 22);
							data_tmp(5 downto 0)  <= data_in(5 downto 0);
						end if;
					else
						valid_tmp <= '0';
						data_sel <= '0';
					end if;

				when "0110" => -- 6: select CH2 and Digital D11 to D6
					if wr_en = '1' then
						if data_sel = '0' then
							data_sel <= '1';
							valid_tmp <= '0';
							data_tmp(31 downto 22) <= data_in(21 downto 12);
							data_tmp(21 downto 16) <= data_in(11 downto 6);
						else
							data_sel <= '0';
							valid_tmp <= '1';
							data_tmp(15 downto 6) <= data_in(21 downto 12);
							data_tmp(5 downto 0)  <= data_in(11 downto 6);
						end if;
					else
						valid_tmp <= '0';
						data_sel <= '0';
					end if;

				when "0101" => -- 5: select CH2 and Digital D5 to D0
					if wr_en = '1' then
						if data_sel = '0' then
							data_sel <= '1';
							valid_tmp <= '0';
							data_tmp(31 downto 22) <= data_in(21 downto 12);
							data_tmp(21 downto 16) <= data_in(5 downto 0);
						else
							data_sel <= '0';
							valid_tmp <= '1';
							data_tmp(15 downto 6) <= data_in(21 downto 12);
							data_tmp(5 downto 0)  <= data_in(5 downto 0);
						end if;
					else
						valid_tmp <= '0';
						data_sel <= '0';
					end if;

				when others =>
					data_tmp <= data_in;
					valid_tmp <= wr_en;
					
			end case;

		end if;

	end process;

end Behavioral;
