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
    field_enable_out : out   std_logic_vector(7 downto 0)
  );
end entity top;

architecture rtl of top is

  signal tick_1s : std_logic;

begin

  seconds_counter_inst : entity work.binary_counter(rtl)
    generic map (
      max_value => clock_frequency
    )
    port map (
      clk_in       => clk_in,
      count_enable => '1',
      reset_in     => reset_in,
      overflow_out => tick_1s,
      count_out    => open
    );

end architecture rtl;
