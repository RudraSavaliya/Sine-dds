library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sine_ru_pkg.all;

entity sine_core_ru_e is
    port (
        clk_i    : in  std_logic;
        rst_n_i  : in  std_logic;

        coef0_i  : in  reg_t;
        coef1_i  : in  reg_t;
        coef2_i  : in  reg_t;
        coef3_i  : in  reg_t;
        coef4_i  : in  reg_t;
        coef5_i  : in  reg_t;
        coef6_i  : in  reg_t;
        coef7_i  : in  reg_t;

        freq_i   : in  reg_t;   -- frequency control (8-bit)

        sine_o   : out sine_t
    );
end entity sine_core_ru_e;
