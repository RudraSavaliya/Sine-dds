library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sine_ru_pkg is

    constant reg_width_c   : integer := 8;   -- 8-bit registers
    constant phase_width_c : integer := 16;  -- phase accumulator width
    constant sine_resy_c   : integer := 8;   -- 8-bit sine output

    constant lut_size_c    : integer := 8;    -- number of quarter-wave entries
    constant max_val_c     : integer := 255;  -- full-scale for 8-bit amplitude
    subtype reg_t     is std_logic_vector(reg_width_c-1 downto 0);
    subtype sine_t    is std_logic_vector(sine_resy_c-1 downto 0);
    subtype phase_t   is unsigned(phase_width_c-1 downto 0);

    type coef_array_t is array (0 to lut_size_c-1) of reg_t;

end package sine_ru_pkg;
