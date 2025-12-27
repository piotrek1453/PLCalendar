library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity display_driver is
  generic (
    overflow_value     : integer range 0 to 9 := 9;
    invert_segment_out : boolean              := FALSE
  );
  port (
    clk_in              : in    std_logic;
    reset_in            : in    std_logic;
    count_enable        : in    std_logic;
    dot_in              : in    std_logic;
    display_segment_out : out   std_logic_vector(7 downto 0);
    overflow_out        : out   std_logic
  );
end entity display_driver;

architecture rtl of display_driver is

  signal count            : std_logic_vector(3 downto 0);
  signal display_segments : std_logic_vector(7 downto 0);

begin

  counter_inst : entity work.binary_counter(rtl)
    generic map (
      max_value => overflow_value
    )
    port map (
      clk_in       => clk_in,
      reset_in     => reset_in,
      count_enable => count_enable,
      overflow_out => overflow_out,
      count_out    => count
    );

  decoder_proc : process (count, dot_in) is
  begin

    display_segments(0) <= dot_in;

    case count is

      when "0000" =>

        display_segments(7 downto 1) <= "1111110";

      when "0001" =>

        display_segments(7 downto 1) <= "0110000";

      when "0010" =>

        display_segments(7 downto 1) <= "1101101";

      when "0011" =>

        display_segments(7 downto 1) <= "1111001";

      when "0100" =>

        display_segments(7 downto 1) <= "0110011";

      when "0101" =>

        display_segments(7 downto 1) <= "1011011";

      when "0110" =>

        display_segments(7 downto 1) <= "1011111";

      when "0111" =>

        display_segments(7 downto 1) <= "1110000";

      when "1000" =>

        display_segments(7 downto 1) <= "1111111";

      when "1001" =>

        display_segments(7 downto 1) <= "1111011";

      when others =>

        display_segments(7 downto 1) <= "1111110";

    end case;

  end process decoder_proc;

  display_segment_out <= display_segments when invert_segment_out else
                         not display_segments;

end architecture rtl;
