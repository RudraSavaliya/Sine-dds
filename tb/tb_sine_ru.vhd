library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sine_ru_pkg.all;

entity tb_sine_ru is
end entity tb_sine_ru;

architecture tb of tb_sine_ru is

    constant clk_period_c   : time    := 10 ns;
    constant sim_cycles_c   : integer := 5000;  -- total simulation cycles


    constant sine_zero_c    : sine_t := (others => '0');

    signal clk_s    : std_logic := '0';
    signal rst_n_s  : std_logic := '0';

    signal reg01_s  : reg_t;
    signal reg02_s  : reg_t;
    signal reg03_s  : reg_t;
    signal reg04_s  : reg_t;
    signal reg05_s  : reg_t;
    signal reg06_s  : reg_t;
    signal reg07_s  : reg_t;
    signal reg08_s  : reg_t;
    signal reg09_s  : reg_t;

    signal sine_s   : sine_t;

begin

    ----------------------------------------------------------------
    -- Clock generation
    ----------------------------------------------------------------
    clk_s <= not clk_s after clk_period_c/2;

    ----------------------------------------------------------------
    -- DUT instantiation
    ----------------------------------------------------------------
    uut : entity work.sine_ru_e
        port map (
            clk_i   => clk_s,
            rst_n_i => rst_n_s,

            reg01_i => reg01_s,
            reg02_i => reg02_s,
            reg03_i => reg03_s,
            reg04_i => reg04_s,
            reg05_i => reg05_s,
            reg06_i => reg06_s,
            reg07_i => reg07_s,
            reg08_i => reg08_s,
            reg09_i => reg09_s,

            sine_o  => sine_s
        );

    ----------------------------------------------------------------
    -- Stimulus and self-checks
    ----------------------------------------------------------------
    stim_proc : process
    begin
        -- Initial reset and zero configuration
        rst_n_s <= '0';
        reg01_s <= (others => '0');
        reg02_s <= (others => '0');
        reg03_s <= (others => '0');
        reg04_s <= (others => '0');
        reg05_s <= (others => '0');
        reg06_s <= (others => '0');
        reg07_s <= (others => '0');
        reg08_s <= (others => '0');
        reg09_s <= (others => '0');
        wait for 5*clk_period_c;

        rst_n_s <= '1';
        wait for 5*clk_period_c;

        --CHECK 1:
       
        wait for 20*clk_period_c;
        assert sine_s = sine_zero_c
          report "REQ1 FAILED: sine output not zero while freq = 0"
          severity error;

       
        reg01_s <= x"98";  -- 0°
        reg02_s <= x"B0";  -- 11.25°
        reg03_s <= x"C6";  -- 22.5°
        reg04_s <= x"DA";  -- 33.75°
        reg05_s <= x"EA";  -- 45°
        reg06_s <= x"F5";  -- 56.25°
        reg07_s <= x"FD";  -- 67.5°
        reg08_s <= x"FF";  -- 90°

       
        reg09_s <= x"40";

        -- CHECK 2:
        
        wait for 100*clk_period_c;
        assert sine_s /= sine_zero_c
          report "REQ2 FAILED: sine output still zero after run enabled"
          severity error;

        wait for sim_cycles_c * clk_period_c;

        assert false
          report "tb_sine_ru finished"
          severity note;
        wait;
    end process;

end architecture tb;









        -- Run for a few cycles
--        wait for 5000*clk_period_c;

--        assert false report "tb_sine_ru finished" severity note;
--        wait;
--    end process;

--end architecture tb;
