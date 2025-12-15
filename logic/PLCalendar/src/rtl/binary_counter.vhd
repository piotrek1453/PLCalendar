library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity binary_counter is
  generic (
    max_value : integer := 27000000 -- 1s tick with 27 MHz
  );
  port (
    clk_in       : in    std_logic;
    count_enable : in    std_logic;
    reset_in     : in    std_logic;
    overflow_out : out   std_logic;
    count_out    : out   std_logic
  );
end entity binary_counter;

architecture rtl of binary_counter is

  constant counter_width : integer := integer(ceil(log2(real(max_value))));

  type counter_state_t is (s_reset, s_count, s_overflow);

  attribute syn_encoding                    : string;
  attribute syn_encoding of counter_state_t : type is "onehot";
  signal current_state, next_state : counter_state_t;

  signal counter_reg,   next_counter  : std_logic_vector(counter_width - 1 downto 0);
  signal overflow_reg,  next_overflow : std_logic;

begin

  overflow_out <= overflow_reg;

  counter_fsm_sequential : process (clk_in, reset_in) is
  begin

    if (reset_in = '0') then
      current_state <= s_reset;
      counter_reg   <= (others => '0');
      overflow_reg  <= '0';
      next_counter  <= (others => '0');
      next_overflow <= '0';
      next_state    <= s_reset;
    elsif rising_edge(clk_in) then
      if (count_enable = '1') then
        current_state <= next_state;
        counter_reg   <= next_counter;
        overflow_reg  <= next_overflow;
      end if;
      count_out <= counter_reg;
    end if;

  end process counter_fsm_sequential;

  counter_fsm_combinatorial : process (all) is
  begin

    next_state    <= current_state;
    next_counter  <= counter_reg;
    next_overflow <= '0';

    case current_state is

      when s_reset =>

        next_counter  <= (others => '0');
        next_overflow <= '0';
        next_state    <= s_count;

      when s_count =>

        if (unsigned(counter_reg) = to_unsigned(max_value - 1, counter_width)) then
          next_state <= s_overflow;
        else
          next_state <= s_count;
        end if;

        next_counter  <= std_logic_vector(unsigned(counter_reg) + 1);
        next_overflow <= '0';

      when s_overflow =>

        next_counter  <= (others => '0');
        next_overflow <= '1';
        next_state    <= s_count;

    end case;

  end process counter_fsm_combinatorial;

end architecture rtl;
