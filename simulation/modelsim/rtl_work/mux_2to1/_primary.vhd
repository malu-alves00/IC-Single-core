library verilog;
use verilog.vl_types.all;
entity mux_2to1 is
    port(
        a               : in     vl_logic_vector(31 downto 0);
        b               : in     vl_logic_vector(31 downto 0);
        control         : in     vl_logic;
        \out\           : out    vl_logic_vector(31 downto 0)
    );
end mux_2to1;
