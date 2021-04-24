----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/03/01 20:51:59
-- Design Name: 
-- Module Name: main - Behavioral
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

entity main is
PORT(   Hsync, Vsync: OUT STD_LOGIC;      -- Horizontal and vertical sync pulses for VGA
          -- 4-bit colour values output to DAC on Basys 3 board
          vgaRed, vgaBlue, vgaGreen: OUT STD_LOGIC_VECTOR(3 downto 0);
          CLK: IN STD_LOGIC;                -- 50 MHz clock
          sw: IN unsigned(15 downto 8);     -- Switches for velocity input
          btnC, btnU, btnL, btnR: IN STD_LOGIC;         -- Pushbuttons for go and reset respectively
          seg: OUT STD_LOGIC_VECTOR(6 downto 0); -- 7-seg cathodes 
          an: OUT STD_LOGIC_VECTOR(3 downto 0)   -- 7-seg anodes       
          );
end main;

architecture Behavioral of main is

component frq_div
    generic( n : integer);  -- frq_div_coefficient
    Port (  clkin : in STD_LOGIC;
            clkout : out std_logic
            );
end component;

component vga_controller_640_60
port(
   rst         : in std_logic;
   pixel_clk   : in std_logic;

   HS          : out std_logic;
   VS          : out std_logic;
   hcount      : out unsigned(10 downto 0);
   vcount      : out unsigned(10 downto 0);
   blank       : out std_logic
);
end component;

component drawing 
  Port (
        hcount, vcount : in unsigned(10 downto 0); 
        blank : in std_logic;
        rst, btnC, btnL, btnR : in std_logic; 
        sw : in unsigned(15 downto 8); 
        vgaR, vgaB, vgaG : out std_logic_vector(3 downto 0);
        scores : out std_logic_vector(13 downto 0)  -- upto 9999
        );
end component;

component data2seg
  Port (clk : in std_logic;
        data : in std_logic_vector(13 downto 0);  -- upto 9999
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0) );
end component;

signal points : std_logic_vector(6 downto 0);
signal scores : std_logic_vector(13 downto 0);
signal blank : std_logic;
signal clk25Mhz : std_logic;

signal hcount : unsigned(10 downto 0);
signal vcount : unsigned(10 downto 0);


begin

inst_frq_div : frq_div  -- f_clkin = 100Mhz
generic map(n => 4)  -- 100Mhz/4 = 25Mhz
port map(clkin => CLK, clkout => clk25Mhz);

-- the points you got are displayed on the four_digits.
inst_vga_controller_640_60:vga_controller_640_60
port map(rst=>btnU, pixel_clk=>clk25Mhz, HS=>Hsync, VS=>Vsync,
hcount=>hcount, vcount=>vcount, blank=>blank);

inst_drawing : drawing
port map(hcount=>hcount, vcount=>vcount, blank=>blank,
        rst=>btnU, btnC=>btnC, btnL=>btnL, btnR=>btnR,
        sw=>sw, vgaR=>vgaRed, vgaB=>vgaBlue, vgaG=>vgaGreen,
        scores=>scores);

inst_data2seg : data2seg
port map(clk=>clk25Mhz, data=>scores, seg=>seg, an=>an);


end Behavioral;
