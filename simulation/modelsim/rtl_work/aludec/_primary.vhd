library verilog;
use verilog.vl_types.all;
entity aludec is
    port(
        op_bit          : in     vl_logic;
        funct3          : in     vl_logic_vector(2 downto 0);
        funct7b5        : in     vl_logic;
        alu_op          : in     vl_logic_vector(1 downto 0);
        alu_control     : out    vl_logic_vector(2 downto 0)
    );
end aludec;
