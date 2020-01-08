--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--! @File        : GeneralComponents_pkg.vhd
--! @Brief       : Package file containing general components and functions
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
--! 1. Counters     : UpCount, UpCountLd, UpCountRstnLd, DownCount, DownCountLd,
--!                   UpDownCount, UpDownCountLd, StepCount
--! 2. Multiplexers : Mux2, Mux2N, Mux3, Mux3N, Mux4, Mux4N, Mux5, Mux5N,
--!                   Mux6, Mux6N, Mux8, Mux8N
--! 3. Registers    : Reg, RegN, RegNLd
--! 4. Memories     : SPDRam, SPBRam, DPDRam, DPBRam
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package GeneralComponents_pkg is
    
    --==========================================================================
    --! 1. COUNTERS
    ----------------------------------------------------------------------------
    --  UpCount, UpCountLd, UpCountRstLd, DownCount, DownCountLd, 
    --  UpDownCount, UpDownCountLd, StepCount
    --==========================================================================
     
    COMPONENT UpCountRst
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : IN  STD_LOGIC;
                rst         : IN  STD_LOGIC;
                en          : IN  STD_LOGIC;
                count       : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
            );  
    END COMPONENT;  
    
    COMPONENT UpCountLd
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : IN  STD_LOGIC;
                en          : IN  STD_LOGIC;
                len         : IN  STD_LOGIC;
                load        : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0);
                count       : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
            );  
    END COMPONENT;  
    
    COMPONENT UpDownLd  
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : IN  STD_LOGIC;
                len         : IN  STD_LOGIC;
                load        : IN  STD_LOGIC_VECTOR(N     -1 DOWNTO 0);
                en          : IN  STD_LOGIC;
                count       : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
            );  
    END COMPONENT;  
   
    COMPONENT UpCountRstLd  
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : IN  STD_LOGIC;
                rst         : IN  STD_LOGIC;
                len         : IN  STD_LOGIC;
                load        : IN  STD_LOGIC_VECTOR(N     -1 DOWNTO 0);
                en          : IN  STD_LOGIC;
                count       : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
            );  
    END COMPONENT;  
    
    COMPONENT UpDownRstLd  
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : IN  STD_LOGIC;
                rst         : IN  STD_LOGIC;
                len         : IN  STD_LOGIC;
                load        : IN  STD_LOGIC_VECTOR(N     -1 DOWNTO 0);
                en          : IN  STD_LOGIC;
                count       : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
            );  
    END COMPONENT;  


    COMPONENT DownCount 
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : IN  STD_LOGIC;
                rst         : IN  STD_LOGIC;
                en          : IN  STD_LOGIC;
                count       : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT DownCountLd
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : IN  STD_LOGIC;
                len         : IN  STD_LOGIC;
                load        : IN  STD_LOGIC_VECTOR(N     -1 DOWNTO 0);
                en          : IN  STD_LOGIC;
                count       : OUT STD_LOGIC_VECTOR(N     -1 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT UpDownCountRst
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : in  STD_LOGIC;
                rst         : in  STD_LOGIC;
                en          : in  STD_LOGIC;
                up          : in  STD_LOGIC;
                count       : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );
    END COMPONENT;

    COMPONENT UpDownCountLd
    generic (   N           : INTEGER:=8 );
    port    (   
                clk         : in  STD_LOGIC;
                len         : in  STD_LOGIC;
                en          : in  STD_LOGIC;
                up          : in  STD_LOGIC;
                load        : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                count       : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );  
    END COMPONENT;  
    
    COMPONENT StepCountRst 
    generic (   N           : INTEGER:=8;-- N of counter
                limit       : INTEGER:=8;-- Counter limit
                step        : INTEGER:=2  --step value
            );  
    port    (   
                clk         :in  STD_LOGIC;
                rst         :in  STD_LOGIC;
                ena         :in  STD_LOGIC;
                count       :out STD_LOGIC_VECTOR(N     -1 downto 0)
            );
    END COMPONENT;
    
    COMPONENT StepDownCountLd 
    generic (   N           : INTEGER:=8;-- N of counter
                step        : INTEGER:=2  --step value
            );  
    port    (   
                clk         :in  STD_LOGIC;
                len         :in  STD_LOGIC;
                ena         :in  STD_LOGIC;
                load        :in STD_LOGIC_VECTOR(N     -1 downto 0);
                count       :out STD_LOGIC_VECTOR(N     -1 downto 0)
            );
    END COMPONENT;
    --==========================================================================

    --==========================================================================
    --! 2. Multiplexers
    ----------------------------------------------------------------------------
    --  Mux2, Mux2N, Mux3, Mux3N, Mux4, Mux4N, Mux5, Mux5N, Mux6, Mux6N,
    --  Mux8, Mux8N
    --==========================================================================

    COMPONENT Mux2
    port    (
                M0          : in  STD_LOGIC;
                M1          : in  STD_LOGIC;
                sel         : in  STD_LOGIC;
                Mout        : out STD_LOGIC
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux2N     
    generic (   N           : INTEGER:=8 );
    port    (       
                M0          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M1          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                sel         : in  STD_LOGIC;    
                Mout        : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux3      
    port    (       
                M0          : in  STD_LOGIC;
                M1          : in  STD_LOGIC;
                M2          : in  STD_LOGIC;
                sel         : in  STD_LOGIC_VECTOR(2    -1 downto 0);
                Mout        : out STD_LOGIC
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux3N     
    generic (   N           : INTEGER:=8 );
    port    (       
                M0          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M1          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M2          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                sel         : in  STD_LOGIC_VECTOR(2    -1 downto 0);
                Mout        : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );  
    
    END COMPONENT;  
    
    COMPONENT Mux4  
    port    (   
                M0          : in  STD_LOGIC;
                M1          : in  STD_LOGIC;
                M2          : in  STD_LOGIC;
                M3          : in  STD_LOGIC;
                sel         : in  STD_LOGIC_VECTOR(2    -1 downto 0);
                Mout        : out STD_LOGIC
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux4N     
    generic (   N           : INTEGER:=8 );
    port    (       
                M0          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M1          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M2          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M3          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                sel         : in  STD_LOGIC_VECTOR(2    -1 downto 0);
                Mout        : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux5      
    port    (       
                M0          : in  STD_LOGIC;
                M1          : in  STD_LOGIC;
                M2          : in  STD_LOGIC;
                M3          : in  STD_LOGIC;
                M4          : in  STD_LOGIC;
                sel         : in  STD_LOGIC_VECTOR(3    -1 downto 0);
                Mout        : out STD_LOGIC
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux5N     
    generic (   N           : INTEGER:=8 );
    port    (       
                M0          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M1          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M2          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M3          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M4          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                sel         : in  STD_LOGIC_VECTOR(3    -1 downto 0);
                Mout        : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux6      
    port    (       
                M0          : in  STD_LOGIC;
                M1          : in  STD_LOGIC;
                M2          : in  STD_LOGIC;
                M3          : in  STD_LOGIC;
                M4          : in  STD_LOGIC;
                M5          : in  STD_LOGIC;
                sel         : in  STD_LOGIC_VECTOR(3    -1 downto 0);
                Mout        : out STD_LOGIC
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux6N     
    generic (   N           : INTEGER:=8 );
    port    (       
                M0          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M1          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M2          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M3          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M4          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M5          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                sel         : in  STD_LOGIC_VECTOR(3    -1 downto 0);
                Mout        : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux8      
    port    (       
                M0          : in  STD_LOGIC;
                M1          : in  STD_LOGIC;
                M2          : in  STD_LOGIC;
                M3          : in  STD_LOGIC;
                M4          : in  STD_LOGIC;
                M5          : in  STD_LOGIC;
                M6          : in  STD_LOGIC;
                M7          : in  STD_LOGIC;
                sel         : in  STD_LOGIC_VECTOR(3    -1 downto 0);
                Mout        : out STD_LOGIC
            );      
        
    END COMPONENT;      
        
    COMPONENT Mux8N     
    generic (   N           : INTEGER:=8 );
    port    (       
                M0          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M1          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M2          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M3          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M4          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M5          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M6          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                M7          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
                sel         : in  STD_LOGIC_VECTOR(3    -1 downto 0);
                Mout        : out STD_LOGIC_VECTOR(N    -1 downto 0)
            );

    END COMPONENT;
    --==========================================================================

    --==========================================================================
    --! 3.REGISTERS
    ----------------------------------------------------------------------------
    --  Reg, RegLd, RegN, RegNLd
    --==========================================================================
    COMPONENT Reg
    PORT(
               clk          : in  STD_LOGIC;
               ena          : in  STD_LOGIC;
               din          : in  STD_LOGIC;
               dout         : out STD_LOGIC
         );     
    END COMPONENT;      
    
    COMPONENT RegLd
    PORT(
               clk          : in  STD_LOGIC;
               ena          : in  STD_LOGIC;
               len          : in  STD_LOGIC;
               load         : in  STD_LOGIC;
               din          : in  STD_LOGIC;
               dout         : out STD_LOGIC
         );     
    END COMPONENT;      
        
    COMPONENT RegN      
    generic (   N           : INTEGER:=8 );
    port    (       
               clk          : in  STD_LOGIC;
               ena          : in  STD_LOGIC;
               din          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
               dout         : out STD_LOGIC_VECTOR(N    -1 downto 0)
             );     
    END COMPONENT;      
        
    COMPONENT RegNLd        
    generic (  N            : INTEGER:=8 );
    port    (       
               clk          : in  STD_LOGIC;
               ena          : in  STD_LOGIC;
               len          : in  STD_LOGIC;
               load         : in  STD_LOGIC_VECTOR(N    -1 downto 0);
               din          : in  STD_LOGIC_VECTOR(N    -1 downto 0);
               dout         : out STD_LOGIC_VECTOR(N    -1 downto 0)
             );
    END COMPONENT;
    --==========================================================================

    --==========================================================================
    --! 4.Memories
    ----------------------------------------------------------------------------
    --  SPDRam, SPBRam, DPDRam, DPBRam
    --==========================================================================
    COMPONENT SPDRam
    generic (   DataWidth   : INTEGER ;
                AddrWidth   : INTEGER
            );
    port    (
                clk         : in  STD_LOGIC;
                wen         : in  STD_LOGIC;
                addr        : in  STD_LOGIC_VECTOR(AddrWidth  -1 downto 0);
                din         : in  STD_LOGIC_VECTOR(DataWidth  -1 downto 0);
                dout        : out STD_LOGIC_VECTOR(DataWidth  -1 downto 0)
            );
    END COMPONENT;

    COMPONENT SPBRam
    generic (   DataWidth   : INTEGER ;
                AddrWidth   : INTEGER
            );
    port    (
                clk         : in  STD_LOGIC;
                wen         : in  STD_LOGIC;
                addr        : in  STD_LOGIC_VECTOR(AddrWidth  -1 downto 0);
                din         : in  STD_LOGIC_VECTOR(DataWidth  -1 downto 0);
                dout        : out STD_LOGIC_VECTOR(DataWidth  -1 downto 0)
            );

    END COMPONENT;

    COMPONENT DPDRam
    generic (   DataWidth   : INTEGER;
                AddrWidth   : INTEGER
            );
    port    (
                clk         : in  STD_LOGIC;
                wenA        : in  STD_LOGIC;
               -- wenB        : in  STD_LOGIC;
                addrA       : in  STD_LOGIC_VECTOR(AddrWidth    -1 downto 0);
                addrB       : in  STD_LOGIC_VECTOR(AddrWidth    -1 downto 0);
                dinA        : in  STD_LOGIC_VECTOR(DataWidth    -1 downto 0);
                dinB        : in  STD_LOGIC_VECTOR(DataWidth    -1 downto 0);
                doutA       : out STD_LOGIC_VECTOR(DataWidth    -1 downto 0);
                doutB       : out STD_LOGIC_VECTOR(DataWidth    -1 downto 0)
            );
    END COMPONENT;

    COMPONENT DPBRam
    generic (   DataWidth   : INTEGER;
                AddrWidth   : INTEGER
            );
    port    (
                clk         : in  STD_LOGIC;
                wenA        : in  STD_LOGIC;
                wenB        : in  STD_LOGIC;
                enA         : in  STD_LOGIC;
                enB         : in  STD_LOGIC;
                setRstA     : in  STD_LOGIC;
                setRstB     : in  STD_LOGIC;
                addrA       : in  STD_LOGIC_VECTOR(AddrWidth    -1 downto 0);
                addrB       : in  STD_LOGIC_VECTOR(AddrWidth    -1 downto 0);
                dinA        : in  STD_LOGIC_VECTOR(DataWidth    -1 downto 0);
                dinB        : in  STD_LOGIC_VECTOR(DataWidth    -1 downto 0);
                doutA       : out STD_LOGIC_VECTOR(DataWidth    -1 downto 0);
                doutB       : out STD_LOGIC_VECTOR(DataWidth    -1 downto 0)
            );
    END COMPONENT;
    --==========================================================================

end GeneralComponents_pkg;

package body GeneralComponents_pkg is


end GeneralComponents_pkg;
