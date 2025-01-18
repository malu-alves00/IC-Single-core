`timescale 1ns/1ps

module tb_data_mem;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter DATA_DEPTH = 128;
    parameter INDEX_WIDTH = $clog2(DATA_DEPTH);

    // Testbench signals
    logic [INDEX_WIDTH-1:0] address;
    logic [DATA_WIDTH-1:0] write_data;
    logic clk, wr;
    logic [DATA_WIDTH-1:0] read_data;
    
    logic [INDEX_WIDTH-1:0] address_debug;
    logic enable_read_debug;
    logic [DATA_WIDTH-1:0] read_data_debug;

    // DUT instantiation
    data_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) dut (
        .address(address),
        .write_data(write_data),
        .clk(clk),
        .wr(wr),
        .read_data(read_data),
        .address_debug(address_debug),
        .enable_read_debug(enable_read_debug),
        .read_data_debug(read_data_debug)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        wr = 0;
        address = 0;
        write_data = 0;
        address_debug = 0;
        enable_read_debug = 0;

        // Write data to memory
        @(posedge clk);
        wr = 1;
        address = 5;
        write_data = 32'hDEADBEEF;
        @(posedge clk);
        wr = 0;

        // Read data from memory
        @(posedge clk);
        address = 5;
        #1; // Small delay for read propagation
        assert(read_data == 32'hDEADBEEF) else $fatal("Read data mismatch!");

        // Debug read
        @(posedge clk);
        address_debug = 5;
        enable_read_debug = 1;
        @(posedge clk);
        #1; // Small delay for debug read propagation
        assert(read_data_debug == 32'hDEADBEEF) else $fatal("Debug read data mismatch!");
        enable_read_debug = 0;

        // Test high-impedance debug output
        @(posedge clk);
        #1; // Small delay for high-impedance propagation
        assert(read_data_debug === 32'bz) else $fatal("Debug read_data_debug should be high-impedance!");

        // Finish simulation
        $display("All tests passed!");
        $finish;
    end

endmodule