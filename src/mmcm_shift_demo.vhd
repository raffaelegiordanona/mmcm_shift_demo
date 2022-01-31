----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2022 11:45:56 AM
-- Design Name: 
-- Module Name: mmcm_shift_demo - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mmcm_shift_demo is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           set : in STD_LOGIC;
           phase : in STD_LOGIC_VECTOR (9 downto 0);
           done : out STD_LOGIC;
           clk_shifted : out STD_LOGIC);
end mmcm_shift_demo;

architecture Behavioral of mmcm_shift_demo is

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Dynamic phase shift ports
  psclk             : in     std_logic;
  psen              : in     std_logic;
  psincdec          : in     std_logic;
  psdone            : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

component phase_shifter is
    Port ( psclk      : in STD_LOGIC;
           psdone     : in STD_LOGIC;
           locked     : in STD_LOGIC;
           reset_in   : in STD_LOGIC;
           set        : in STD_LOGIC;
           phase      : in STD_LOGIC_VECTOR(9 downto 0); -- max 1023
           reset_out  : out STD_LOGIC;
           psen       : out STD_LOGIC;
           psincdec   : out STD_LOGIC;
           done       : out STD_LOGIC);
end component;

signal reset_from_ps, reset_mmcm, psdone, psclk, psen, psincdec, locked : std_logic;


begin


mmcm_shift_fsm: phase_shifter 
   port map ( 
    psclk   => clk,
    psdone => psdone,
    locked => locked,
    reset_in => rst,
    set => set,
    phase => phase,
    reset_out => reset_from_ps,
    psen => psen,
    psincdec => psincdec,
    done => done
    );

reset_mmcm <= reset_from_ps or rst;

mmcm_i : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_shifted,
  -- Dynamic phase shift ports                 
   psclk => clk,
   psen => psen,
   psincdec => psincdec,
   psdone => psdone,
  -- Status and control signals                
   reset => reset_mmcm,
   locked => locked,
   -- Clock in ports
   clk_in1 => clk
 );
end Behavioral;
