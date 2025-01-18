library verilog;
use verilog.vl_types.all;
entity full_decoder is
    port(
        zero            : in     vl_logic;
        op              : in     vl_logic_vector(6 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        funct7          : in     vl_logic;
        control_word    : out    vl_logic_vector(10 downto 0)
    );
end full_decoder;
