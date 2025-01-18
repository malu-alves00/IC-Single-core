module tb_full_decoder;

  // Testbench signals
  logic       zero;
  logic [6:0] op;
  logic [2:0] funct3;
  logic       funct7;
  logic [10:0] control_word;

  // Instantiate the DUT (Device Under Test)
  full_decoder dut (
    .zero(zero),
    .op(op),
    .funct3(funct3),
    .funct7(funct7),
    .control_word(control_word)
  );

  // Test stimulus
  initial begin
    $display("Starting Full Decoder Testbench...");
    $display("zero |   op    | funct3 | funct7 | control_word");

    // Test Case 1: Load Word (lw)
    zero = 1'b0;
    op = 7'b0000011;
    funct3 = 3'b000;
    funct7 = 1'b0;
    #10;
    $display("%b    | %b | %b   | %b     | %b", zero, op, funct3, funct7, control_word);

    // Test Case 2: Store Word (sw)
    zero = 1'b0;
    op = 7'b0100011;
    funct3 = 3'b000;
    funct7 = 1'b0;
    #10;
    $display("%b    | %b | %b   | %b     | %b", zero, op, funct3, funct7, control_word);

    // Test Case 3: R-Type Operation (add)
    zero = 1'b0;
    op = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 1'b0;
    #10;
    $display("%b    | %b | %b   | %b     | %b", zero, op, funct3, funct7, control_word);

    // Test Case 4: Branch (beq)
    zero = 1'b1;
    op = 7'b1100011;
    funct3 = 3'b000;
    funct7 = 1'b0;
    #10;
    $display("%b    | %b | %b   | %b     | %b", zero, op, funct3, funct7, control_word);

    // Test Case 5: Default case
    zero = 1'b0;
    op = 7'b1111111;
    funct3 = 3'b111;
    funct7 = 1'b1;
    #10;
    $display("%b    | %b | %b   | %b     | %b", zero, op, funct3, funct7, control_word);

    $display("Testbench Completed.");
    $stop;
  end

endmodule