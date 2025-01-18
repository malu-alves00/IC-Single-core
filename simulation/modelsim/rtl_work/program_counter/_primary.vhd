library verilog;
use verilog.vl_types.all;
entity program_counter is
    generic(
        INSTR_WIDTH     : integer := 32
    );
    port(
        PC_next         : in     vl_logic_vector(15 downto 0);
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        PC_state        : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INSTR_WIDTH : constant is 1;
end program_counter;
