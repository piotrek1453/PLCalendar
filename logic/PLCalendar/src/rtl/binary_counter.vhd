library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity binary_counter is
  generic (
    COUNTER_LEN : integer := 32
  );
  port (
    countIn     : in std_logic;
    resetIn     : in std_logic;
    countOut    : out std_logic_vector(COUNTER_LEN - 1 downto 0);
    overflowOut : out std_logic
  );
end entity;

architecture rtl of binary_counter is
  type counter_state_t is (S_RESET, S_COUNT, S_OVERFLOW);
  attribute syn_encoding                    : string;
  attribute syn_encoding of counter_state_t : type is "onehot";
  signal current_state, next_state          : counter_state_t := S_RESET;

  signal counter_reg, next_counter   : std_logic_vector(COUNTER_LEN - 1 downto 0) := (others => '0');
  signal overflow_reg, next_overflow : std_logic                                  := '0';
begin

  countOut    <= counter_reg;
  overflowOut <= overflow_reg;

  counter_fsm_sequential : process (countIn, resetIn) begin
    if resetIn = '0' then
      current_state <= S_RESET;
      counter_reg   <= ((others => '0'));
      overflow_reg  <= '0';
    elsif rising_edge(countIn) then
      current_state <= next_state;
      counter_reg   <= next_counter;
      overflow_reg  <= next_overflow;
    end if;
  end process;

  counter_fsm_combinatorial : process (all) is
  begin
    next_state <= current_state;
    -- next_counter  <= counter_reg;
    next_overflow <= '0';

    case current_state is
      when S_RESET              =>
        next_counter  <= ((others => '0'));
        next_overflow <= '0';
        next_state    <= S_COUNT;

      when S_COUNT =>
        next_counter  <= std_logic_vector(unsigned(counter_reg) + to_unsigned(1, COUNTER_LEN));
        next_overflow <= '0';
        if counter_reg = (counter_reg'range => '1') then
          next_state <= S_OVERFLOW;
        else
          next_state <= S_COUNT;
        end if;

      when S_OVERFLOW           =>
        next_counter  <= ((others => '0'));
        next_overflow <= '1';
        next_state    <= S_COUNT;

    end case;
  end process;

end architecture;
