library verilog;
use verilog.vl_types.all;
entity extend is
    port(
        instr           : in     vl_logic_vector(31 downto 7);
        immsrc          : in     vl_logic_vector(1 downto 0);
        immext          : out    vl_logic_vector(31 downto 0)
    );
end extend;
