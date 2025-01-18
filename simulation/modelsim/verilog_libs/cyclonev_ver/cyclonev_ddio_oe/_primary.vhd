library verilog;
use verilog.vl_types.all;
entity cyclonev_ddio_oe is
    generic(
        power_up        : string  := "low";
        async_mode      : string  := "none";
        sync_mode       : string  := "none";
        lpm_type        : string  := "cyclonev_ddio_oe";
        disable_second_level_register: string  := "false"
    );
    port(
        oe              : in     vl_logic;
        octreadcontrol  : in     vl_logic;
        clk             : in     vl_logic;
        ena             : in     vl_logic;
        areset          : in     vl_logic;
        sreset          : in     vl_logic;
        dataout         : out    vl_logic;
        dfflo           : out    vl_logic;
        dffhi           : out    vl_logic;
        devpor          : in     vl_logic;
        devclrn         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of power_up : constant is 1;
    attribute mti_svvh_generic_type of async_mode : constant is 1;
    attribute mti_svvh_generic_type of sync_mode : constant is 1;
    attribute mti_svvh_generic_type of lpm_type : constant is 1;
    attribute mti_svvh_generic_type of disable_second_level_register : constant is 1;
end cyclonev_ddio_oe;