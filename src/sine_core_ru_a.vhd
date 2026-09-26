library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sine_ru_pkg.all;

architecture sine_core_ru_a of sine_core_ru_e is

    ----------------------------------------------------------------
    -- FSM states
    ----------------------------------------------------------------
    type fsm_state_t is (ST_RESET, ST_WAIT, ST_UPDATE);
    signal state_r, state_n : fsm_state_t;

    ----------------------------------------------------------------
    -- Internal registers
    ----------------------------------------------------------------
    signal phase_s : unsigned(4 downto 0);   -- 0..31
    signal timer_s : unsigned(31 downto 0);
    signal timer_t : unsigned(31 downto 0);

    signal coef_s  : coef_array_t;
    signal sine_s  : sine_t;

    -- Clock frequency constant
    constant clk_freq_c    : integer := 125_000_000;
    constant phase_steps_c : integer := 32;

begin

    ----------------------------------------------------------------
    -- Coefficient mapping (quarter-wave)
    ----------------------------------------------------------------
    coef_s(0) <= coef0_i;
    coef_s(1) <= coef1_i;
    coef_s(2) <= coef2_i;
    coef_s(3) <= coef3_i;
    coef_s(4) <= coef4_i;
    coef_s(5) <= coef5_i;
    coef_s(6) <= coef6_i;
    coef_s(7) <= coef7_i;

    ----------------------------------------------------------------
    -- Timer target calculation (PROCESS, not concurrent)
    ----------------------------------------------------------------
   process(freq_i)
    variable freq_v   : integer;
    variable target_v : integer;
begin
    freq_v := to_integer(unsigned(freq_i));

    if freq_v <= 0 then
                                                                   -- Safe default: stop timer
        timer_t <= (others => '0');
    else
        target_v :=
            (clk_freq_c / freq_v) / phase_steps_c - 1;

   
        if target_v < 0 then
            target_v := 0;
        end if;

        timer_t <= to_unsigned(target_v, timer_t'length);
    end if;
end process;



    ----------------------------------------------------------------
    -- FSM state register
    ----------------------------------------------------------------
    process(clk_i, rst_n_i)
    begin
        if rst_n_i = '0' then
            state_r <= ST_RESET;
        elsif rising_edge(clk_i) then
            state_r <= state_n;
        end if;
    end process;

    ----------------------------------------------------------------
    -- FSM next-state logic
    ----------------------------------------------------------------
    process(state_r, timer_s, timer_t, freq_i)
    begin
        state_n <= state_r;

        case state_r is
            when ST_RESET =>
                if unsigned(freq_i) /= 0 then
                    state_n <= ST_WAIT;
                end if;

            when ST_WAIT =>
                if timer_s = timer_t then
                    state_n <= ST_UPDATE;
                end if;

            when ST_UPDATE =>
                state_n <= ST_WAIT;
        end case;
    end process;

    ----------------------------------------------------------------
    -- Datapath: timer, phase, sine generation
    ----------------------------------------------------------------
    process(clk_i, rst_n_i)
        variable quad_v : unsigned(1 downto 0);
        variable idx_v  : integer range 0 to lut_size_c-1;
        variable eff_v  : integer range 0 to lut_size_c-1;
        variable base_v : integer;
        variable samp_v : integer;
    begin
        if rst_n_i = '0' then
            timer_s <= (others => '0');
            phase_s <= (others => '0');
            sine_s  <= (others => '0');

        elsif rising_edge(clk_i) then
            case state_r is

                when ST_RESET =>
                    timer_s <= (others => '0');
                    phase_s <= (others => '0');
                    sine_s  <= (others => '0');

                when ST_WAIT =>
                    timer_s <= timer_s + 1;

                when ST_UPDATE =>
                    timer_s <= (others => '0');
                    phase_s <= phase_s + 1;

                    -- quadrant and index
                    quad_v := phase_s(4 downto 3);
                    idx_v  := to_integer(phase_s(2 downto 0));

                    -- mirroring
                    if quad_v = "00" or quad_v = "10" then
                        eff_v := idx_v;
                    else
                        eff_v := (lut_size_c - 1) - idx_v;
                    end if;

                    -- coefficient lookup
                    base_v := to_integer(unsigned(coef_s(eff_v)));

                    -- sign inversion
                    if quad_v = "10" or quad_v = "11" then
                        samp_v := max_val_c - base_v;
                    else
                        samp_v := base_v;
                    end if;

                    sine_s <= std_logic_vector(
                                to_unsigned(samp_v, sine_resy_c));

            end case;
        end if;
    end process;

    sine_o <= sine_s;

end architecture sine_core_ru_a;



























--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use work.sine_ru_pkg.all;

--architecture sine_core_ru_a of sine_core_ru_e is

--    ----------------------------------------------------------------
--    -- FSM declaration (Moore, 3 states as per lecture)
--    ----------------------------------------------------------------
--    type fsm_state_t is (RESET_S, LOAD_S, RUN_S);
--    signal state_r, state_n : fsm_state_t;

--    ----------------------------------------------------------------
--    -- Datapath
--    ----------------------------------------------------------------
--    signal phase_s : phase_t;
--    signal coef_s  : coef_array_t;
--    signal run_en  : std_logic;
--    signal sine_s  : sine_t;
--begin

--    ----------------------------------------------------------------
--    -- Coefficient mapping (DO NOT CHANGE)
--    ----------------------------------------------------------------
--    coef_s(0) <= coef0_i;
--    coef_s(1) <= coef1_i;
--    coef_s(2) <= coef2_i;
--    coef_s(3) <= coef3_i;
--    coef_s(4) <= coef4_i;
--    coef_s(5) <= coef5_i;
--    coef_s(6) <= coef6_i;
--    coef_s(7) <= coef7_i;

--    ----------------------------------------------------------------
--    -- FSM: State Register (Process 1)
--    ----------------------------------------------------------------
--    process(clk_i, rst_n_i)
--    begin
--        if rst_n_i = '0' then
--            state_r <= RESET_S;
--        elsif rising_edge(clk_i) then
--            state_r <= state_n;
--        end if;
--    end process;

--    ----------------------------------------------------------------
--    -- FSM: Next-State + run_en
--    ----------------------------------------------------------------
--    process(state_r, freq_i)
--        variable freq_zero_v : unsigned(freq_i'length-1 downto 0);
--    begin
--        freq_zero_v := (others => '0');
--        state_n     <= state_r;
--        run_en      <= '0';

--        case state_r is
--            when RESET_S =>
--                if unsigned(freq_i) /= freq_zero_v then
--                    state_n <= LOAD_S;
--                end if;

--            when LOAD_S =>
--                state_n <= RUN_S;

--            when RUN_S =>
--                run_en <= '1';
--                if unsigned(freq_i) = freq_zero_v then
--                    state_n <= RESET_S;
--                end if;
--        end case;
--    end process;

--    ----------------------------------------------------------------
--    -- Datapath: phase accumulator + quarter-wave mirroring
--    ----------------------------------------------------------------
--    process(clk_i, rst_n_i)
--        variable quad_v : unsigned(1 downto 0);
--        variable idx_v  : integer range 0 to lut_size_c-1;
--        variable eff_v  : integer range 0 to lut_size_c-1;
--        variable base_v : integer;
--        variable samp_v : integer;
--    begin
--        if rst_n_i = '0' then
--            phase_s <= (others => '0');
--            sine_s  <= (others => '0');

--        elsif rising_edge(clk_i) then
--            if run_en = '1' then
--                -- 1) phase accumulator
--                phase_s <= phase_s + resize(unsigned(freq_i), phase_width_c);

--                -- 2) quadrant and index
--                quad_v := phase_s(15 downto 14);
--                idx_v  := to_integer(phase_s(13 downto 11));

--                -- 3) symmetric mirroring
--                if quad_v = "00" or quad_v = "10" then
--                    eff_v := idx_v;
--                else
--                    eff_v := (lut_size_c-1) - idx_v;
--                end if;

--                -- 4) lookup
--                base_v := to_integer(unsigned(coef_s(eff_v)));

--                -- 5) sign for lower half
--                if quad_v = "10" or quad_v = "11" then
--                    samp_v := max_val_c - base_v;
--                else
--                    samp_v := base_v;
--                end if;

--                sine_s <= std_logic_vector(to_unsigned(samp_v, sine_resy_c));
--            end if;
--        end if;
--    end process;

--    sine_o <= sine_s;

--end architecture sine_core_ru_a;














--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use work.sine_ru_pkg.all;

--architecture sine_core_ru_a of sine_core_ru_e is

--    signal phase_s : phase_t;
--    signal coef_s  : coef_array_t;

--begin

--    -- Map coefficients (0..90°)
--    coef_s(0) <= coef0_i;
--    coef_s(1) <= coef1_i;
--    coef_s(2) <= coef2_i;
--    coef_s(3) <= coef3_i;
--    coef_s(4) <= coef4_i;
--    coef_s(5) <= coef5_i;
--    coef_s(6) <= coef6_i;
--    coef_s(7) <= coef7_i;

--    process(clk_i, rst_n_i)
--        variable phase_next_v : phase_t;

--        variable quad_v  : unsigned(1 downto 0);
--        variable idx_v   : integer range 0 to 6;
--        variable eff_v   : integer range 0 to 6;

--        variable base_v  : integer;
--        variable sample  : integer;
--    begin
--        if rst_n_i = '0' then
--            phase_s <= (others => '0');
--            sine_o  <= (others => '0');

--        elsif rising_edge(clk_i) then

--            ------------------------------------------------------------
--            -- 1. PHASE ACCUMULATOR (USE NEXT PHASE)
--            ------------------------------------------------------------
--            phase_next_v := phase_s + resize(unsigned(freq_i), phase_width_c);
--            phase_s      <= phase_next_v;

--            ------------------------------------------------------------
--            -- 2. DECODE FROM UPDATED PHASE
--            ------------------------------------------------------------
--            quad_v := phase_next_v(15 downto 14);

--            idx_v := to_integer(phase_next_v(13 downto 11));
--           -- if idx_v = 7 then
--              --  idx_v := 6;   -- clamp to avoid double peak
--            --end if;

--            ------------------------------------------------------------
--            -- 3. MIRROR INDEX (NO DUPLICATION)
--            ------------------------------------------------------------
--            if quad_v = "00" or quad_v = "10" then
--                eff_v := idx_v;
--            else
--                eff_v := 7 - idx_v;
--            end if;

--            ------------------------------------------------------------
--            -- 4. LOOKUP
--            ------------------------------------------------------------
--            base_v := to_integer(unsigned(coef_s(eff_v)));

--            ------------------------------------------------------------
--            -- 5. NEGATIVE HALF
--            ------------------------------------------------------------
--            if quad_v = "10" or quad_v = "11" then
--                sample := 255 - base_v;
--            else
--                sample := base_v;
--            end if;

--            sine_o <= std_logic_vector(to_unsigned(sample, 8));
--        end if;
--    end process;

--end architecture sine_core_ru_a;
