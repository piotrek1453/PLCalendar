library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity top is
  generic (
    clock_frequency  : positive := 27000000;
    number_of_digits : positive := 4
  );
  port (
    clk_in           : in    std_logic;
    reset_in         : in    std_logic;
    digit_enable_out : out   std_logic_vector(number_of_digits - 1 downto 0);
    field_enable_out : out   std_logic_vector(7 downto 0);
    led_out          : out   std_logic
  );
end entity top;

architecture rtl of top is

  type digit_switching_array is array(0 to number_of_digits - 1) of std_logic_vector(7 downto 0);

  signal digit_switching_regs : digit_switching_array;
  signal current_digit_index  : integer range 0 to number_of_digits - 1;
  signal tick_1s              : std_ulogic;
  signal overflow_carry       : std_ulogic_vector(number_of_digits - 1 downto 0);

begin

  digit_sweeper_proc : process (clk_in, reset_in) is
  begin

    -- TODO: fix the sweeping logic: digits are shifted left one position
    if (reset_in = '0') then
      digit_enable_out    <= STD_LOGIC_VECTOR(to_unsigned(1, digit_enable_out'length));
      current_digit_index <= 0;
    elsif rising_edge(clk_in) then
      digit_enable_out    <= digit_enable_out(digit_enable_out'length - 2 downto 0) & digit_enable_out(digit_enable_out'length - 1);
      current_digit_index <= current_digit_index + 1;
      field_enable_out    <= digit_switching_regs(current_digit_index);
    end if;

  end process digit_sweeper_proc;

  one_second_tick_inst : entity work.binary_counter(rtl)
    port map (
      clk_in       => not clk_in,
      reset_in     => reset_in,
      count_enable => '1',
      overflow_out => tick_1s,
      count_out    => open
    );

  seconds_digit_inst : entity work.display_driver(rtl)
    port map (
      clk_in              => clk_in,
      reset_in            => reset_in,
      count_enable        => tick_1s,
      dot_in              => tick_1s,
      display_segment_out => digit_switching_regs(0),
      overflow_out        => overflow_carry(0)
    );

  tens_of_seconds_digit_inst : entity work.display_driver(rtl)
    port map (
      clk_in              => clk_in,
      reset_in            => reset_in,
      count_enable        => overflow_carry(0),
      dot_in              => tick_1s,
      display_segment_out => digit_switching_regs(1),
      overflow_out        => overflow_carry(1)
    );

end architecture rtl;
