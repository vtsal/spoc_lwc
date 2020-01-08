--------------------------------------------------------------------------------
--! @File        : RegN.vhd
--! @Brief       : n-bit register
--!
--! @Author      : Panasayya Yalla
--! @Copyright   : Copyright © 2016 Cryptographic Engineering Research Group
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
--! N (Integer)  : Generic value to set the size
--! clk          : Clock
--! en           : Enable
--! din[N-1:0]   : Counter output
--! dout[N-1:0]  : Counter output
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity RegN is 
    generic (   N   : integer:=8 );
    port    (
                clk : in  std_logic;
                ena : in  std_logic;
                din : in  std_logic_vector(N-1 downto 0);
                dout: out std_logic_vector(N-1 downto 0)
             );
end RegN;

architecture RegN of RegN is 
	signal qnext:std_logic_vector(N-1 downto 0);
begin	
	
reg: 	process(clk)
		begin
			if rising_edge(clk) then 
				if ena ='1' then
					qnext <= din; 
				end if;
			end if; 
		end process;
	  dout<=qnext;
  
end RegN;
