----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/03/05 11:34:04
-- Design Name: 
-- Module Name: drawing - Behavioral
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

entity drawing is
  Port (
        hcount, vcount : in unsigned(10 downto 0); 
        blank : in std_logic;
        rst, btnC, btnL, btnR : in std_logic; 
        sw : in unsigned(15 downto 8); 
        vgaR, vgaB, vgaG : out std_logic_vector(3 downto 0);
        scores : out std_logic_vector(13 downto 0)
        );
end drawing;

architecture Behavioral of drawing is

constant BALL_R : integer := 20;  -- radius
constant BALL_R2 : integer := 400;  -- radius^2
constant STICK_W : integer := 60;
constant STICK_H : integer := 20;

constant WALL_L : integer := 0;
constant WALL_R : integer := 639;
constant WALL_T : integer := 0;
constant WALL_B : integer := 479;

constant STICK_RBG : std_logic_vector(11 downto 0) := "000011110000";  -- PINK
constant BALL_RBG : std_logic_vector(11 downto 0) := "111100001111";  -- green
-- when the game is over, the screen will turn red.
signal background : std_logic_vector(11 downto 0) := "000000000000";

-- some default value is declared here
constant STICK_L_DEF : integer := WALL_L;
constant STICK_R_DEF : integer := WALL_L + STICK_W - 1;
constant STICK_B : integer := WALL_B - 10;
constant STICK_T : integer := STICK_B - STICK_H + 1;

constant BALL_X_DEF : integer :=20;
constant BALL_Y_DEF : integer :=20;

constant STICK_SPD : integer := 20;

signal x : integer;
signal y : integer;
signal ball_on :std_logic;
signal stick_on :std_logic;

signal points : unsigned(13 downto 0):=(others=>'0');
signal points_p1 : unsigned(13 downto 0):=(others=>'0');
signal bravo : std_logic:='0';  -- a rising edge when the ball hits the bar and bounce back
signal setgo : std_logic:='0';  -- default mode is 'set'.
signal setgo_n : std_logic;
signal frame : std_logic;

-- position of the left and right boundary of the stick
signal stick_l : integer;
signal stick_r : integer;

-- position and next position of the ball
signal nx_cx : integer;
signal nx_cy : integer;
signal cx : integer;
signal cy : integer;

-- temp signal when drawing the ball
signal dx, dy : integer;
signal dx2,dy2 : integer ;

-- current and next horizontal speed and vertical speed of the ball.
signal ball_spd_x : integer;
signal ball_spd_y : integer;
signal nx_ball_spd_x : integer;
signal nx_ball_spd_y : integer;

-- ball collision indicator
signal colli_l_wall : std_logic;  -- left hand side collision against wall
signal colli_r_wall : std_logic;  -- right hand side collision against wall
signal colli_t_wall : std_logic;  -- top collision against wall
signal colli_b_wall : std_logic;  -- bottom collision against wall
--signal colli_l_stick : std_logic;  -- left hand side collision against stick
--signal colli_r_stick : std_logic;  -- right hand side collision against stick
--signal colli_t_stick : std_logic;  -- top collision against stick
signal colli_b_stick : std_logic;  -- bottom collision against stick

BEGIN
------------------------------------------------------------------------
-------------------------- concurrent part -----------------------------
------------------------------------------------------------------------
    x <= to_integer(hcount);
    y <= to_integer(vcount);

    -- drawing ball
    dx <= x - cx when x > cx else cx - x;
    dy <= y - cy when y > cy else cy - y;
    dx2 <= dx * dx;
    dy2 <= dy * dy;
    ball_on <= '1' when (dx2 + dy2 < BALL_R2) else '0';  -- x^2+y^2<R^2
    
    -- determine speed of the ball in next frame
    -- if hits the wall or stick, it will bounce back.
    -- a point will be awarded when hits stick.
    colli_l_wall <= '1' when (cx + ball_spd_x - BALL_R <= WALL_L)
                        else '0';
--    colli_l_stick <= '1' when (cx+ball_spd_x-BALL_R<=stick_r and cx+ball_spd_x-BALL_R>stick_l and cy+ball_spd_y+BALL_R>=STICK_T and cy+ball_spd_y-BALL_R<=STICK_B)
--                        else '0';
    colli_r_wall <= '1' when (cx + ball_spd_x + BALL_R >= WALL_R)                     
                        else '0';  
--    colli_r_stick <= '1' when (cx+ball_spd_x+BALL_R>=stick_l and cx+ball_spd_x+BALL_R<stick_r and cy+ball_spd_y+BALL_R>=STICK_T and cy+ball_spd_y-BALL_R<=STICK_B)
--                        else '0';
    colli_t_wall <= '1' when (cy + ball_spd_y - BALL_R <= WALL_T)
                        else '0';
--    colli_t_stick <= '1' when (cy+ball_spd_y-BALL_R<=STICK_B and cy+ball_spd_y-BALL_R>STICK_T and cx+ball_spd_x+BALL_R>=stick_l and cx+ball_spd_x-BALL_R<=stick_r)
--                        else '0';
    colli_b_wall <= '1' when (cy + ball_spd_y + BALL_R >= WALL_B)                
                        else '0';
    colli_b_stick <= '1' when (cy+ball_spd_y+BALL_R>=STICK_T and cy+ball_spd_y+BALL_R<STICK_B and cx+ball_spd_x+BALL_R>=stick_l and cx+ball_spd_x-BALL_R<=stick_r)
                        else '0';
                        
    nx_ball_spd_x <= - ball_spd_x when (colli_l_wall='1' or colli_r_wall='1' ) else
--                                        or colli_l_stick='1' or colli_r_stick='1')
                                0 when colli_b_wall='1'
                    else ball_spd_x;

    nx_ball_spd_y <= - ball_spd_y when (colli_t_wall='1' or colli_b_stick='1') else  -- or colli_t_stick='1'
                                0 when colli_b_wall='1'   
                    else ball_spd_y;
                        
    -- determine next position of the ball by current position and speed.
--    nx_cx <=    STICK_R + BALL_R when colli_l_stick='1' else
--                STICK_L - BALL_R when colli_r_stick='1' else
        nx_cx <=    WALL_R - BALL_R when colli_r_wall='1' else
                    WALL_L + BALL_R when colli_l_wall='1' else
                    cx + ball_spd_x;
                    
        nx_cy <=    STICK_T - BALL_R when colli_b_stick='1' else
--                    STICK_B + BALL_R when colli_t_stick='1' else
                    WALL_T + BALL_R when colli_t_wall='1' else
                    WALL_B - BALL_R when colli_b_wall='1' else
                    cy + ball_spd_y;

        bravo <= '1' when  colli_b_stick='1' 
                        else '0';
    
--  drawing stick
    stick_on <= '1' when (x>=stick_l and x<=stick_r and y>=STICK_T and y<=STICK_B) else
                '0';

    frame <= '1' when y>WALL_B else
                '0';
                
    -- if hits the BOTTOM, the ball will stop and the game is over
    -- screen turns red.
    background <= "111100000000" when colli_b_wall='1' else
                    (others=>'0');
    
    -- vga generation
    vgaR <=   (others=>'0') when blank='1' else
                BALL_RBG(11 downto 8) when ball_on='1' else
                STICK_RBG(11 downto 8) when stick_on='1' else
                background(11 downto 8);
    vgaB <=  (others=>'0') when blank='1' else
                BALL_RBG(7 downto 4) when ball_on='1' else
                STICK_RBG(7 downto 4) when stick_on='1' else
                background(7 downto 4);
    vgaG <= (others=>'0') when blank='1' else
                BALL_RBG(3 downto 0) when ball_on='1' else
                STICK_RBG(3 downto 0) when stick_on='1' else
                background(3 downto 0);

-------------------------------------------------------------------------------------
------------------------------- sequential part ------------------------------------
-------------------------------------------------------------------------------------
    mode : process(rst, btnC)
    begin
        if rst='1' then
            setgo <= '0';
        elsif rising_edge(btnC) then
            setgo <= setgo_n;
        end if;
    end process;
    setgo_n <= not setgo;

    -- drawing update circuit
    stick_update: process(setgo, rst, frame, btnR, btnL)
    variable nx_stick_l : integer;
    variable nx_stick_r: integer;
    begin
        if rst='1' then  -- reset
            -- reset position of the ball
            cx <= BALL_X_DEF;
            cy <= BALL_Y_DEF;
            -- read the speed of the ball from switches
            ball_spd_x <= to_integer(sw(15 downto 12));
            ball_spd_y <= to_integer(sw(11 downto 8));
            -- reset the stick
            nx_stick_l := STICK_L_DEF;
            nx_stick_r := STICK_R_DEF;
        elsif rising_edge(frame) and setgo='1' then
            -- update the ball
            cx <= nx_cx;
            cy <= nx_cy;
            ball_spd_x <= nx_ball_spd_x;
            ball_spd_y <= nx_ball_spd_y;
            -- controlling the stick
            if btnL='1' then  -- move left
                if stick_l - STICK_SPD >= WALL_L then
                    nx_stick_l := stick_l - STICK_SPD;
                    nx_stick_r := stick_r - STICK_SPD;
                else  -- arrive the left boundary of the screen
                    nx_stick_l := WALL_L;
                    nx_stick_r := WALL_L + STICK_W - 1;
                end if;
            elsif btnR='1' then  -- move right
                if stick_r + STICK_SPD <= WALL_R then
                    nx_stick_l := stick_l + STICK_SPD;
                    nx_stick_r := stick_r + STICK_SPD;
                else  -- arrive the right boundary of the screen
                    nx_stick_l := WALL_R - STICK_W + 1;
                    nx_stick_r := WALL_R;
                end if;
            end if;
        end if;
        stick_l <= nx_stick_l; 
        stick_r <= nx_stick_r;
    end process;

    points_awarding:process(bravo, rst)
    begin
        if rst='1' then
            points <= (others=>'0');
        elsif rising_edge(bravo) then
            points <= points_p1;
        end if;
    end process;
    points_p1 <= points + 1;
    scores <= std_logic_vector(points);

end Behavioral;
