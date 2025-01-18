library verilog;
use verilog.vl_types.all;
entity instr_mem_rom is
    port(
        address         : in     vl_logic_vector(6 downto 0);
        clock           : in     vl_logic;
        q               : out    vl_logic_vector(31 downto 0)
    );
end instr_mem_rom;
