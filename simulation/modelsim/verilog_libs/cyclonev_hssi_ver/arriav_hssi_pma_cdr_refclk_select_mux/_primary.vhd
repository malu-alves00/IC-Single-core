library verilog;
use verilog.vl_types.all;
entity arriav_hssi_pma_cdr_refclk_select_mux is
    generic(
        lpm_type        : string  := "arriav_hssi_pma_cdr_refclk_select_mux";
        channel_number  : integer := 0;
        mux_type        : string  := "cdr_refclk_select_mux";
        refclk_select   : string  := "ref_iqclk0";
        reference_clock_frequency: string  := "0 ps";
        avmm_group_channel_index: integer := 0;
        use_default_base_address: string  := "true";
        user_base_address: integer := 0;
        inclk0_logical_to_physical_mapping: string  := "";
        inclk1_logical_to_physical_mapping: string  := "";
        inclk2_logical_to_physical_mapping: string  := "";
        inclk3_logical_to_physical_mapping: string  := "";
        inclk4_logical_to_physical_mapping: string  := "";
        inclk5_logical_to_physical_mapping: string  := "";
        inclk6_logical_to_physical_mapping: string  := "";
        inclk7_logical_to_physical_mapping: string  := "";
        inclk8_logical_to_physical_mapping: string  := "";
        inclk9_logical_to_physical_mapping: string  := "";
        inclk10_logical_to_physical_mapping: string  := "";
        inclk11_logical_to_physical_mapping: string  := "";
        inclk12_logical_to_physical_mapping: string  := "";
        inclk13_logical_to_physical_mapping: string  := "";
        inclk14_logical_to_physical_mapping: string  := "";
        inclk15_logical_to_physical_mapping: string  := "";
        inclk16_logical_to_physical_mapping: string  := "";
        inclk17_logical_to_physical_mapping: string  := "";
        inclk18_logical_to_physical_mapping: string  := "";
        inclk19_logical_to_physical_mapping: string  := "";
        inclk20_logical_to_physical_mapping: string  := "";
        inclk21_logical_to_physical_mapping: string  := "";
        inclk22_logical_to_physical_mapping: string  := "";
        inclk23_logical_to_physical_mapping: string  := "";
        inclk24_logical_to_physical_mapping: string  := "";
        inclk25_logical_to_physical_mapping: string  := ""
    );
    port(
        calclk          : in     vl_logic;
        refclklc        : in     vl_logic;
        occalen         : in     vl_logic;
        ffplloutbot     : in     vl_logic;
        ffpllouttop     : in     vl_logic;
        pldclk          : in     vl_logic;
        refiqclk0       : in     vl_logic;
        refiqclk1       : in     vl_logic;
        refiqclk10      : in     vl_logic;
        refiqclk2       : in     vl_logic;
        refiqclk3       : in     vl_logic;
        refiqclk4       : in     vl_logic;
        refiqclk5       : in     vl_logic;
        refiqclk6       : in     vl_logic;
        refiqclk7       : in     vl_logic;
        refiqclk8       : in     vl_logic;
        refiqclk9       : in     vl_logic;
        rxiqclk0        : in     vl_logic;
        rxiqclk1        : in     vl_logic;
        rxiqclk10       : in     vl_logic;
        rxiqclk2        : in     vl_logic;
        rxiqclk3        : in     vl_logic;
        rxiqclk4        : in     vl_logic;
        rxiqclk5        : in     vl_logic;
        rxiqclk6        : in     vl_logic;
        rxiqclk7        : in     vl_logic;
        rxiqclk8        : in     vl_logic;
        rxiqclk9        : in     vl_logic;
        avmmclk         : in     vl_logic;
        avmmrstn        : in     vl_logic;
        avmmwrite       : in     vl_logic;
        avmmread        : in     vl_logic;
        avmmbyteen      : in     vl_logic_vector(1 downto 0);
        avmmaddress     : in     vl_logic_vector(10 downto 0);
        avmmwritedata   : in     vl_logic_vector(15 downto 0);
        avmmreaddata    : out    vl_logic_vector(15 downto 0);
        blockselect     : out    vl_logic;
        clkout          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of lpm_type : constant is 1;
    attribute mti_svvh_generic_type of channel_number : constant is 1;
    attribute mti_svvh_generic_type of mux_type : constant is 1;
    attribute mti_svvh_generic_type of refclk_select : constant is 1;
    attribute mti_svvh_generic_type of reference_clock_frequency : constant is 1;
    attribute mti_svvh_generic_type of avmm_group_channel_index : constant is 1;
    attribute mti_svvh_generic_type of use_default_base_address : constant is 1;
    attribute mti_svvh_generic_type of user_base_address : constant is 1;
    attribute mti_svvh_generic_type of inclk0_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk1_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk2_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk3_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk4_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk5_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk6_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk7_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk8_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk9_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk10_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk11_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk12_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk13_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk14_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk15_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk16_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk17_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk18_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk19_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk20_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk21_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk22_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk23_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk24_logical_to_physical_mapping : constant is 1;
    attribute mti_svvh_generic_type of inclk25_logical_to_physical_mapping : constant is 1;
end arriav_hssi_pma_cdr_refclk_select_mux;
