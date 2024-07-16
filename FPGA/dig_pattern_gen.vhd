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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dig_pattern_gen is
	generic (
		DIG_MAX_SAMPLES : integer := 32768
	);
    Port (
		clk_in : in  STD_LOGIC;
		digitalPatternOutputEn : in  STD_LOGIC;
		digitalPatternOutputMode : in STD_LOGIC;
		digitalPatternOutputRestart : in  STD_LOGIC;
		digitalClkDivide : in STD_LOGIC_VECTOR (31 downto 0);
		data_in   : in  STD_LOGIC_VECTOR (11 downto 0);
		data_out  : out STD_LOGIC_VECTOR (11 downto 0);
		addrb_dig : out STD_LOGIC_VECTOR (14 downto 0));
end dig_pattern_gen;

architecture Behavioral of dig_pattern_gen is

	signal cntState : std_logic_vector(1 downto 0):="00";
	CONSTANT CNT_A: std_logic_vector(1 DownTo 0) := "00";
	CONSTANT CNT_B: std_logic_vector(1 DownTo 0) := "01";
	CONSTANT CNT_C: std_logic_vector(1 DownTo 0) := "10";
	CONSTANT CNT_D: std_logic_vector(1 DownTo 0) := "11";

	signal counter : unsigned(31 downto 0);
	signal digitalClkDivide_cnt   : unsigned(31 downto 0) := to_unsigned(0,32);
	signal digitalClkDivide_cnt_d : unsigned(31 downto 0) := to_unsigned(0,32);
	signal digitalClkEn    : std_logic := '0';
	signal digitalClkEn_d  : std_logic := '0';
	signal digitalClkEn_dd : std_logic := '0';
	signal addrb_dig_i : std_logic_vector(14 downto 0) := std_logic_vector(to_unsigned(0,15));
	signal addrb_dig_restart   : std_logic := '0';
	signal addrb_dig_restart_d : std_logic := '0';
	
	signal digitalPatternOutputEn_d  : std_logic := '0';
	signal digitalPatternOutputEn_dd : std_logic := '0';
	signal digitalPatternOutputMode_d  : std_logic := '0';
	signal digitalPatternOutputMode_dd : std_logic := '0';
	signal digitalPatternOutputRestart_d  : std_logic := '0';
	signal digitalPatternOutputRestart_dd : std_logic := '0';
	
	signal data_out_en : std_logic := '0';
	
	-- attribute strings
	attribute KEEP: boolean;
	attribute mark_debug: boolean;

	attribute KEEP of digitalPatternOutputEn_dd : signal is true;
	attribute KEEP of digitalPatternOutputMode_dd : signal is true;
	attribute KEEP of digitalPatternOutputRestart_dd : signal is true;
	attribute KEEP of addrb_dig_i : signal is true;
	
	attribute mark_debug of digitalPatternOutputEn_dd : signal is true;
	attribute mark_debug of digitalPatternOutputMode_dd : signal is true;
	attribute mark_debug of digitalPatternOutputRestart_dd : signal is true;
	attribute mark_debug of addrb_dig_i : signal is true;


begin
	
	generate_pattern: process(clk_in)

begin
	
	addrb_dig <= addrb_dig_i;

	if rising_edge(clk_in) then
	
		if digitalClkEn_dd = '1' and data_out_en = '1' then
			data_out <= data_in;
		end if;
		
		digitalPatternOutputEn_d <= digitalPatternOutputEn;
		digitalPatternOutputEn_dd <= digitalPatternOutputEn_d;

		digitalPatternOutputMode_d <= digitalPatternOutputMode;
		digitalPatternOutputMode_dd <= digitalPatternOutputMode_d;

		digitalPatternOutputRestart_d <= digitalPatternOutputRestart;
		digitalPatternOutputRestart_dd <= digitalPatternOutputRestart_d;
		if digitalPatternOutputRestart_dd = '0' and digitalPatternOutputRestart_d = '1' then
			addrb_dig_restart <= '1';
		end if;

		-- digital pattern clock divider
		if digitalPatternOutputEn_dd = '1' then
			if digitalClkDivide_cnt >= unsigned(digitalClkDivide) then
				digitalClkDivide_cnt <= to_unsigned(0,32);
				digitalClkEn <= '1';
			else
				digitalClkDivide_cnt <= digitalClkDivide_cnt + 1;
				digitalClkEn <= '0';
			end if;
		else
			digitalClkEn <= '0';
		end if;
		digitalClkEn_d <= digitalClkEn;
		digitalClkEn_dd <= digitalClkEn_d;
		
		if digitalClkEn_dd = '1' then
				
			case cntState(1 downto 0) is
				
				when CNT_A => -- increment addrb_dig
						
					data_out_en <= '1';
					if ( addrb_dig_i = std_logic_vector(to_unsigned(DIG_MAX_SAMPLES-1,15)) ) then
						if digitalPatternOutputMode_dd = '0' then -- pattern repeat mode: loop
							cntState <= CNT_A; -- restart pattern 
							addrb_dig_i <= "000000000000000";
						else  -- pattern repeat mode: single burst
							cntState <= CNT_B; -- hold addrb_dig
						end if;
					else
						-- if pattern restart command was received
						if addrb_dig_restart = '1' then
							addrb_dig_restart <= '0'; -- reset restart bit
							cntState <= CNT_C;
						else
							addrb_dig_i <= std_logic_vector(unsigned(addrb_dig_i) + 1);
							cntState <= CNT_A;
						end if;
					end if;			
					
				when CNT_B => -- hold addrb_dig after end of pattern
					
					data_out_en <= '0';
					if addrb_dig_restart = '1' then            -- restart pattern (restart command received)
						addrb_dig_restart <= '0'; -- reset restart bit
						cntState <= CNT_C;
					elsif digitalPatternOutputMode_dd = '0' then -- restart pattern (loop mode setting)
						cntState <= CNT_C;
					else
						cntState <= CNT_B;
					end if;				
						
				when CNT_C => -- restart addrb_dig
					
					data_out_en <= '0';
					addrb_dig_i <= "000000000000000";
					cntState <= CNT_A;
						
				when others =>
					
					cntState <= CNT_A;
				
				end case;
				
		end if; --digitalClkEn_d
				
	end if;
			
end process;


end Behavioral;

