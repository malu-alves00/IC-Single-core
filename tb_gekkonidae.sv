module tb_gekkonidae;

  // Clock and reset signals
  logic clk;
  logic reset;

  // instruction memory input debug
logic        instruction_mem_enable_write_debug;
logic [31:0] instruction_mem_write_data_debug;
logic [6:0]  instruction_mem_write_address_debug;


//instruction memory output debug
logic [31:0] instruction_mem_data_out_debug;


// data memory input debug
logic [6:0]   data_mem_read_address_debug;
logic         data_mem_enable_read_debug;
logic [31:0]  data_mem_write_data_debug;

// data memory output debug
logic [31:0]  data_mem_data_out_debug;

// control word quentinho do decoder
logic [10:0]  control_word_debug;

//output pc current state debug
logic [15:0]  pc_value;

logic [31:0]  out_reg_2_debug;

  // old core debug, criar new outro
  Gekkonidae core (
    .clk(clk),
    .reset(reset),
	 
    .instruction_mem_enable_write_debug(instruction_mem_enable_write_debug),
    .instruction_mem_write_data_debug(instruction_mem_write_data_debug),
    .instruction_mem_write_address_debug(instruction_mem_write_address_debug),
	 .instruction_mem_data_out_debug(instruction_mem_data_out_debug),
	 
    .data_mem_read_address_debug(data_mem_read_address_debug),
    .data_mem_enable_read_debug(data_mem_enable_read_debug),
	 .data_mem_write_data_debug(data_mem_write_data_debug),
    .data_mem_data_out_debug(data_mem_data_out_debug),
	 
	 .control_word_debug(control_word_debug),
	 .pc_value(pc_value),
	 
	 .out_reg_2_debug(out_reg_2_debug)
	 
  );

  // Clock generation
  always #5 clk = ~clk;

  // Task to write instructions into instruction memory
  task write_instruction(input [6:0] address, input [31:0] instruction);
    begin
      instruction_mem_enable_write_debug = 1;
      instruction_mem_write_address_debug = address;
      instruction_mem_write_data_debug = instruction;
      @(posedge clk);
      instruction_mem_enable_write_debug = 0;
		$display("Instrucao %b escrita no endereco %b da memoria de instrucoes", instruction, address);
      @(posedge clk);
    end
  endtask
  
  task write_data(input [6:0] address, input [31:0] value);
    begin
		$display("Valor de entrada: %h no endereco %b", value, address);
		data_mem_enable_read_debug = 0;
      data_mem_read_address_debug = address;
      data_mem_write_data_debug = value;
      @(posedge clk);
      data_mem_enable_read_debug = 1;
      @(posedge clk);
    end
  endtask
  
  task read_data(input [6:0] address); // output do valor no data_mem_data_out_debug
    begin
		data_mem_enable_read_debug = 1;
      data_mem_read_address_debug = address;
		@(posedge clk);
		$display("Na posicao %h da memoria de dados ha o valor %h", address, data_mem_data_out_debug);
		@(posedge clk);
    end
  endtask

	task test_lw_sw;
		begin
			// passo 1: escrever valor a ser lido na memória de dados
			write_data(7'b0000100, 32'hAAAABBBB);			
			
			// passo 2: escrever instrução na memória de instruções na posição 0
			write_instruction(7'h00, 32'b000000000100_00000_010_00011_0000011);
			// descrição: pegar o valor da posição x0 + b100 da memória de dados e guardar no registrador 00011
			
			// passo 3: escrever instrução na memória de instruções na posição 4
			write_instruction(7'b0000100, 32'b0000000_00011_00000_010_01010_0100011);
			// descrição: pegar o valor do registrador 00011 e guardar na posição de memória x0 + d10
			
			apply_reset();
			
			
			repeat (4) @(posedge clk);

			read_data(7'b0001010);
			
			repeat (2) @(posedge clk);
	
	
		end
	endtask
  

  // Task to reset the core
  task apply_reset();
    begin
      reset = 1;
      @(posedge clk);
      reset = 0;
    end
  endtask

  // Main test procedure
  initial begin
    // Initialize signals
    clk = 0;
    reset = 0;
    instruction_mem_enable_write_debug = 0; // permitir leitura (0) ou escrita (1) da memória de instruções
    instruction_mem_write_data_debug = 0; // dado a ser escrito na memória de instruções
    instruction_mem_write_address_debug = 0; // endereço para escrita na memória de instruções
    data_mem_read_address_debug = 0; // decide qual o endereço para leitura da memória de dados
    data_mem_enable_read_debug = 1; // ler memória de dados em 1, 0 é para escrever na memória de dados

    // Apply reset
    apply_reset();

    // Load some instructions into the instruction memory
    // Example program:
    // addi x1, x0, 5   --> x1 = 5
    // addi x2, x0, 10  --> x2 = 10
    // add x3, x1, x2   --> x3 = x1 + x2 = 15
    // beq x3, x0, label --> branch if x3 == 0 (should not branch)

    //write_instruction(7'h00, 32'b000000000101_00000_000_00011_0010011); // addi x3, x0, 5
	 //write_instruction(7'h04, 32'b0000000_00011_00000_010_00100_0100011); // sw x3, x0, 4
    //write_instruction(7'h04, 32'b000000001010_00000_000_00010_0010011); // addi x2, x0, 10
    //write_instruction(7'h08, 32'b0000000_00010_00001_000_00011_0110011); // add x3, x1, x2
    //write_instruction(7'h0C, 32'b0000000_00011_00000_000_00100_1100011); // beq x3, x0, label
	 
	 
	 test_lw_sw();

	 
	 
	 
	 
	 
	 /* teste antigo, variáveis não existem
	 
    repeat (20) @(posedge clk); 
	 $display("CW = %d", data_out_debug_instruction_memory);
	 $display("IM read = %d", control_word_debug);

    // Check the results
    address_debug = 7'b0000100;  // olhar posição 4 de memoria
    enable_read_debug = 1;
    
    $display("x1 = %d", read_data_debug);
		
	 #20
	 
    address_debug = 2;  // x2
    @(posedge clk);
    $display("x2 = %d", read_data_debug);

    address_debug = 3;  // x3
    @(posedge clk);
    $display("x3 = %d", read_data_debug);
	
	
    // Stop the simulation
	 */
	 
    $stop;
  end

endmodule
