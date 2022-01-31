
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_mmcm_shift_demo is
end tb_mmcm_shift_demo;

architecture Behavioral of tb_mmcm_shift_demo is

component mmcm_shift_demo is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           set : in STD_LOGIC;
           phase : in STD_LOGIC_VECTOR (9 downto 0);
           done : out STD_LOGIC;
           clk_shifted : out STD_LOGIC);
end component;

constant period : time := 10 ns;


-- inputs
signal clk : std_logic := '0';
signal rst : std_logic;
signal set :   STD_LOGIC;
signal phase :   STD_LOGIC_VECTOR (9 downto 0);   
-- outputs
signal done, clk_shifted : STD_LOGIC;


 signal time_diff : time;
begin

clk_gen : process
begin
  clk <= '1';
  wait for period/2;
  clk <= '0';
  wait for period/2;
end process;


uut: mmcm_shift_demo 
  Port map ( 
           clk => clk, 
           rst => rst, 
           set => set, 
           phase => phase,
           done => done,
           clk_shifted => clk_shifted);

stim_proc:  process
begin
  rst <= '1';
  wait for period*10;
  rst <= '0';
  wait for period;


  set <= '1';
  phase <= "0000000000"; -- 0
  wait for period;
  set <= '0';
  while done = '0'  loop
    wait for period;
  end loop;

  set <= '1';
  phase <= "0010000000"; -- 128
  wait for period;
  set <= '0';
  while done = '0'  loop
    wait for period;
  end loop;
  
    
  set <= '1';
  phase <= "1000000000"; -- 512
  wait for period;
  set <= '0';
  while done = '0'  loop
    wait for period;
  end loop;

  
  wait;
end process stim_proc;

myproc : process
  variable t0,t1 : time;
begin
  
  wait until rising_edge(clk);
  t0 := now;
  wait until rising_edge(clk_shifted);
  t1 := now;
  time_diff <= t1 - t0;
 
end process;

end Behavioral;
