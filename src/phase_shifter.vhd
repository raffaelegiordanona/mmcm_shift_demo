----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2022 11:05:47 AM
-- Design Name: 
-- Module Name: phase_shifter - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity phase_shifter is
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
end phase_shifter;



architecture Behavioral of phase_shifter is

   type state_type is (st_idle, st_reset_pll, st_wait_unlock, st_wait_lock, st_phaseshift, st_waitpsdone, st_done);
   signal state, next_state : state_type;
   signal psen_i, psincdec_i, reset_out_i, done_i : std_logic;  -- example output signal
   signal count : unsigned(9 downto 0);
   
begin
   
  phase_step_counter : process (psclk)
   begin
      if (psclk'event and psclk = '1') then
        if (reset_in = '1') then
             count <= (others => '0');
           elsif set = '1' then
             count <= unsigned(phase);
           elsif psincdec_i = '1' then
             count <= count - 1 ; 
         end if;
   end if;  
   end process;
     
--Insert the following in the architecture after the begin keyword
   SYNC_PROC: process (psclk)
   begin
      if (psclk'event and psclk = '1') then
         if (reset_in = '1') then
            state <= st_idle;
            psen  <= '0';
            psincdec  <= '0';
            reset_out  <= '0';
            done  <= '0';
         else
            state <= next_state;
            psen <= psen_i ;
            psincdec <= psincdec_i ;
            reset_out <= reset_out_i;
            done <= done_i;
         end if;
      end if;
   end process;


   NEXT_STATE_AND_OUTPUT: process (state, psdone, locked, reset_in, set)
   begin
      
      next_state <= state;  --default is to stay in current state
      psen_i <= '0';
      psincdec_i <= '0';
      reset_out_i <= '0';
      done_i <= '0';
            
      case (state) is
         when st_idle =>
            if set = '1' then 
               next_state <= st_reset_pll;
            end if;
         when st_reset_pll =>  -- resets MMCM
             reset_out_i <= '1';
             next_state <= st_wait_unlock;  
          when st_wait_unlock =>  -- waits for unlocking
            if locked = '0' then
               next_state <= st_wait_lock;
            end if;    
         when st_wait_lock =>  -- waits for lock
            if locked = '1' then
               if count = 0  then  
                 next_state <= st_done;
               else                
                 next_state <= st_phaseshift; 
              end if;
            end if;
         when st_phaseshift => -- requests phase shift
            psen_i <= '1';
            psincdec_i <= '1'; 
            next_state <= st_waitpsdone;
         when st_waitpsdone => -- waits for phase shift to complete
           if psdone = '1' then
             if count = 0  then  -- shifted all the steps
               next_state <= st_done;
             else                -- still some steps to shift
               next_state <= st_phaseshift; 
             end if;
           end if;
         when st_done => -- asserts done
           next_state <= st_idle;
           done_i <= '1';
         when others =>
           next_state <= st_idle;
      end case;
   end process;



end Behavioral;
