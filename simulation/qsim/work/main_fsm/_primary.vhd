library verilog;
use verilog.vl_types.all;
entity main_fsm is
    port(
        opcode          : in     vl_logic_vector(6 downto 0);
        alu_op          : out    vl_logic_vector(1 downto 0);
        control_word    : out    vl_logic_vector(6 downto 0)
    );
end main_fsm;
