library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sine_ru_pkg.all;

architecture sine_ru_a of sine_ru_e is

    signal sine_s : sine_t;

begin

    u_core : entity work.sine_core_ru_e
        port map (
            clk_i    => clk_i,
            rst_n_i  => rst_n_i,

            coef0_i  => reg01_i,
            coef1_i  => reg02_i,
            coef2_i  => reg03_i,
            coef3_i  => reg04_i,
            coef4_i  => reg05_i,
            coef5_i  => reg06_i,
            coef6_i  => reg07_i,
            coef7_i  => reg08_i,

            freq_i   => reg09_i,

            sine_o   => sine_s
        );

    sine_o <= sine_s;

end architecture sine_ru_a;
