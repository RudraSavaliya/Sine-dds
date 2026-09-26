library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sine_ru_pkg.all;

entity sine_ru_e is
    port (
        clk_i    : in  std_logic;
        rst_n_i  : in  std_logic;

        reg01_i  : in  reg_t;   -- coef0
        reg02_i  : in  reg_t;   -- coef1
        reg03_i  : in  reg_t;   -- coef2
        reg04_i  : in  reg_t;   -- coef3
        reg05_i  : in  reg_t;   -- coef4
        reg06_i  : in  reg_t;   -- coef5
        reg07_i  : in  reg_t;   -- coef6
        reg08_i  : in  reg_t;   -- coef7
        reg09_i  : in  reg_t;   -- frequency

        sine_o   : out sine_t
    );
end entity sine_ru_e;
