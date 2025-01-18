library verilog;
use verilog.vl_types.all;
entity pc_sum is
    port(
        PC_value        : in     vl_logic_vector(15 downto 0);
        imm_ext         : in     vl_logic_vector(31 downto 0);
        PC_src          : in     vl_logic;
        PC_sum          : out    vl_logic_vector(15 downto 0)
    );
end pc_sum;
