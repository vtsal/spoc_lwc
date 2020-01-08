--------------------------------------------------------------------------------
--! @File        : UpCountRst.vhd
--! @Brief       : N-bit Up counter with load and synchronous reset
--!   ______   ________  _______    ______  
--!  /      \ /        |/       \  /      \ 
--! /$$$$$$  |$$$$$$$$/ $$$$$$$  |/$$$$$$  |
--! $$ |  $$/ $$ |__    $$ |__$$ |$$ | _$$/ 
--! $$ |      $$    |   $$    $$< $$ |/    |
--! $$ |   __ $$$$$/    $$$$$$$  |$$ |$$$$ |
--! $$ \__/  |$$ |_____ $$ |  $$ |$$ \__$$ |
--! $$    $$/ $$       |$$ |  $$ |$$    $$/ 
--!  $$$$$$/  $$$$$$$$/ $$/   $$/  $$$$$$/  
--!
--! @Author      : Panasayya Yalla
--! @Copyright   : Copyright© 2016 Cryptographic Engineering Research Group
--!                ECE Department, George Mason University Fairfax, VA, U.S.A.
--!                All rights Reserved.
--! @license    This project is released under the GNU Public License.          
--!             The license and distribution terms for this file may be         
--!             found in the file LICENSE in this distribution or at            
--!             http://www.gnu.org/licenses/gpl-3.0.txt                         
--! @note       This is publicly available encryption source code that falls    
--!             under the License Exception TSU (Technology and software-       
--!             —unrestricted)                                                  
--------------------------------------------------------------------------------
--! Description
--! clk          : Clock
--! rst          : Active low reset (Synchronous)
--! N (Integer)  : Generic value to set the size
--! en           : Enable
--! count[N-1:0] : Counter output
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity UpCountRst is
    generic (   N     : INTEGER:=8 );
    port    (
                clk   : IN  STD_LOGIC;
                rst   : IN  STD_LOGIC;
                en    : IN  STD_LOGIC;
                count : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
             );
end UpCountRst;

architecture UpCountRst of UpCountRst is
signal qtemp : std_logic_vector(N-1 downto 0);
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if(rst  = '0') then 
                qtemp <= (others=>'0');
            elsif(en  = '1') then
                qtemp <= std_logic_vector(unsigned(qtemp) + 1);
            end if;
        end if;
    end process;
    count <= qtemp;

end UpCountRst;


