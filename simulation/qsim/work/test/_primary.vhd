library verilog;
use verilog.vl_types.all;
entity test is
    port(
        code            : in     vl_logic_vector(1 downto 0);
        word            : out    vl_logic_vector(1 downto 0)
    );
end test;
