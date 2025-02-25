library verilog;
use verilog.vl_types.all;
entity controller is
    port(
        op              : in     vl_logic_vector(6 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        funct7b5        : in     vl_logic;
        Zero            : in     vl_logic;
        ResultSrc       : out    vl_logic_vector(1 downto 0);
        MemWrite        : out    vl_logic;
        PCSrc           : out    vl_logic;
        ALUSrc          : out    vl_logic;
        RegWrite        : out    vl_logic;
        Jump            : out    vl_logic;
        ImmSrc          : out    vl_logic_vector(1 downto 0);
        ALUControl      : out    vl_logic_vector(2 downto 0)
    );
end controller;
