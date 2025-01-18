// gerado com chatgpt porque fiquei com preguiça de fazer >.<

module tb_main_decoder;

  // Testbench signals
  logic [6:0] opcode;
  logic [1:0] alu_op;
  logic [6:0] control_word;

  // Instantiate the DUT (Device Under Test)
  main_decoder uut (
    .opcode(opcode),
    .alu_op(alu_op),
    .control_word(control_word)
  );

  // Test stimulus
  initial begin
    $display("Starting testbench...");

    // Test case 1: Load instruction (opcode = 7'b0000011)
    opcode = 7'b0000011;
    #10;
    $display("Opcode: %b | Control Word: %b | ALU Op: %b", opcode, control_word, alu_op);

    // Test case 2: Store instruction (opcode = 7'b0100011)
    opcode = 7'b0100011;
    #10;
    $display("Opcode: %b | Control Word: %b | ALU Op: %b", opcode, control_word, alu_op);

    // Test case 3: R-type instruction (opcode = 7'b0110011)
    opcode = 7'b0110011;
    #10;
    $display("Opcode: %b | Control Word: %b | ALU Op: %b", opcode, control_word, alu_op);

    // Test case 4: Unknown instruction (default case)
    opcode = 7'b1111111;
    #10;
    $display("Opcode: %b | Control Word: %b | ALU Op: %b", opcode, control_word, alu_op);

    $display("Testbench completed.");
    $stop;
  end

endmodule
