----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/03/06 20:00:07
-- Design Name: 
-- Module Name: data2seg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data2seg is
  Port (clk : in std_logic;
        data : in std_logic_vector(13 downto 0);  -- max 9999
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0) );
end data2seg;

architecture Behavioral of data2seg is
component four_digits
  Port (
      d3 : in std_logic_vector(3 downto 0);
      d2 : in std_logic_vector(3 downto 0);
      d1 : in std_logic_vector(3 downto 0);
      d0 : in std_logic_vector(3 downto 0);
      ck : in std_logic;
      seg : out std_logic_vector(6 downto 0);
      an : out std_logic_vector(3 downto 0)
--        dp : out std_logic
      );
end component;

signal int_data : integer range 0 to 9999:=0;
signal d3 : std_logic_vector(3 downto 0):="0000";
signal d2 : std_logic_vector(3 downto 0):="0000";
signal d1 : std_logic_vector(3 downto 0):="0000";
signal d0 : std_logic_vector(3 downto 0):="0000";

signal d3_rem : integer;
signal d2_rem : integer;
signal d1_rem : integer;


begin
    uut_four_digits : four_digits
        port map ( d3=>d3, d2=>d2, d1=>d1, d0=>d0,
                    ck => clk, seg => seg, an => an); 

    int_data <= to_integer(unsigned(data));

    d1_rem <= d2_rem rem 10;
    d2_rem <= d3_rem rem 100;
    d3_rem <= int_data rem 1000;
    
    d3 <= std_logic_vector(to_unsigned(int_data/1000, 4));
    d2 <= std_logic_vector(to_unsigned(d3_rem/100, 4));
    d1 <= std_logic_vector(to_unsigned(d2_rem/10, 4));
    d0 <= std_logic_vector(to_unsigned(d1_rem, 4));


end Behavioral;
