library verilog;
use verilog.vl_types.all;
entity alu_decoder is
    port(
        funct3          : in     vl_logic_vector(2 downto 0);
        funct7          : in     vl_logic;
        op_bit          : in     vl_logic;
        alu_op          : in     vl_logic_vector(1 downto 0);
        alu_control     : out    vl_logic_vector(2 downto 0)
    );
end alu_decoder;
