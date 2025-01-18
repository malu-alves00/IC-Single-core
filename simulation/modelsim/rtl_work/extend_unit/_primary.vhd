library verilog;
use verilog.vl_types.all;
entity extend_unit is
    port(
        src             : in     vl_logic_vector(24 downto 0);
        imm_src         : in     vl_logic_vector(1 downto 0);
        imm_ext         : out    vl_logic_vector(31 downto 0)
    );
end extend_unit;
