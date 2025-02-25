library verilog;
use verilog.vl_types.all;
entity regfile is
    port(
        clk             : in     vl_logic;
        rw              : in     vl_logic;
        addr1           : in     vl_logic_vector(4 downto 0);
        addr2           : in     vl_logic_vector(4 downto 0);
        wr_address      : in     vl_logic_vector(4 downto 0);
        data_in         : in     vl_logic_vector(31 downto 0);
        data1_out       : out    vl_logic_vector(31 downto 0);
        data2_out       : out    vl_logic_vector(31 downto 0)
    );
end regfile;
