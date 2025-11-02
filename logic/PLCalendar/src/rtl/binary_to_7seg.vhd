library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity binary_to_7seg is
  port (
    binaryValIn      : in std_logic_vector(3 downto 0);
    resetIn          : in std_logic;
    dotIn            : in std_logic;
    segmentEnableOut : out std_logic_vector(7 downto 0)
  );
end entity binary_to_7seg;

architecture rtl of binary_to_7seg is
  subtype decimal_value_s is integer range 0 to 9;
  signal decimal_value : decimal_value_s;
begin

end architecture;
