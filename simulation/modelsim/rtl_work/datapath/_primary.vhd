library verilog;
use verilog.vl_types.all;
entity datapath is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        ResultSrc       : in     vl_logic_vector(1 downto 0);
        PCSrc           : in     vl_logic;
        ALUSrc          : in     vl_logic;
        RegWrite        : in     vl_logic;
        ImmSrc          : in     vl_logic_vector(1 downto 0);
        ALUControl      : in     vl_logic_vector(2 downto 0);
        Zero            : out    vl_logic;
        PC              : out    vl_logic_vector(31 downto 0);
        Instr           : in     vl_logic_vector(31 downto 0);
        ALUResult       : out    vl_logic_vector(31 downto 0);
        WriteData       : out    vl_logic_vector(31 downto 0);
        ReadData        : in     vl_logic_vector(31 downto 0)
    );
end datapath;
