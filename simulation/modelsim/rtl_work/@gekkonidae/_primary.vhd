library verilog;
use verilog.vl_types.all;
entity Gekkonidae is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        control_word_debug: out    vl_logic_vector(10 downto 0);
        pc_value        : out    vl_logic_vector(15 downto 0);
        out_reg_2_debug : out    vl_logic_vector(31 downto 0)
    );
end Gekkonidae;
