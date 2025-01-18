module tb_alu_decoder;

  // Testbench signals
  logic [2:0] funct3;
  logic       funct7;
  logic       op_bit;
  logic [1:0] alu_op;
  logic [2:0] alu_control;

  // Instantiate the DUT (Device Under Test)
  alu_decoder uut (
    .funct3(funct3),
    .funct7(funct7),
    .op_bit(op_bit),
    .alu_op(alu_op),
    .alu_control(alu_control)
  );

  // Test stimulus
  initial begin
    $display("Starting ALU Decoder Testbench...");
    
    // Test Case 1: Load/store operation (matches 7'b00?????)
    alu_op = 2'b00;
    funct3 = 3'b000;
    op_bit = 1'b0;
    funct7 = 1'b0;
    #10;
    $display("TC1 - alu_op: %b | funct3: %b | op_bit: %b | funct7: %b | alu_control: %b", alu_op, funct3, op_bit, funct7, alu_control);
    
    // Test Case 2: Branch operation (matches 7'b01?????)
    alu_op = 2'b01;
    funct3 = 3'b000;
    op_bit = 1'b0;
    funct7 = 1'b0;
    #10;
    $display("TC2 - alu_op: %b | funct3: %b | op_bit: %b | funct7: %b | alu_control: %b", alu_op, funct3, op_bit, funct7, alu_control);

    // Test Case 3: ADD operation (matches 7'b1000000)
    alu_op = 2'b10;
    funct3 = 3'b000;
    op_bit = 1'b0;
    funct7 = 1'b0;
    #10;
    $display("TC3 - alu_op: %b | funct3: %b | op_bit: %b | funct7: %b | alu_control: %b", alu_op, funct3, op_bit, funct7, alu_control);

    // Test Case 4: ADD operation (matches 7'b1000001)
    alu_op = 2'b10;
    funct3 = 3'b000;
    op_bit = 1'b0;
    funct7 = 1'b1;
    #10;
    $display("TC4 - alu_op: %b | funct3: %b | op_bit: %b | funct7: %b | alu_control: %b", alu_op, funct3, op_bit, funct7, alu_control);

    // Test Case 5: ADD operation (matches 7'b1000010)
    alu_op = 2'b10;
    funct3 = 3'b001;
    op_bit = 1'b0;
    funct7 = 1'b0;
    #10;
    $display("TC5 - alu_op: %b | funct3: %b | op_bit: %b | funct7: %b | alu_control: %b", alu_op, funct3, op_bit, funct7, alu_control);

    // Test Case 6: Default case (does not match any condition)
    alu_op = 2'b11;
    funct3 = 3'b111;
    op_bit = 1'b1;
    funct7 = 1'b1;
    #10;
    $display("TC6 - alu_op: %b | funct3: %b | op_bit: %b | funct7: %b | alu_control: %b", alu_op, funct3, op_bit, funct7, alu_control);

    $display("Testbench Completed.");
    $stop;
  end

endmodule
