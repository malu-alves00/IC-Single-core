library verilog;
use verilog.vl_types.all;
entity register_file is
    generic(
        DATA_WIDTH      : integer := 32;
        NUM_REGS        : integer := 32;
        INDEX_WIDTH     : vl_notype
    );
    port(
        clk             : in     vl_logic;
        rw              : in     vl_logic;
        addr1           : in     vl_logic_vector;
        addr2           : in     vl_logic_vector;
        wr_address      : in     vl_logic_vector;
        data_in         : in     vl_logic_vector;
        data1_out       : out    vl_logic_vector;
        data2_out       : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of NUM_REGS : constant is 1;
    attribute mti_svvh_generic_type of INDEX_WIDTH : constant is 3;
end register_file;
