module tb_rvpipeline();
	logic        clk;
	logic        reset, StallF;
	logic [31:0] WriteData, DataAdr, ReadData, InstrF, pcF, Rd1D, Rd2D, ImmExtD, ResultW;
	logic [1:0]  ResultSrcW, ForwardA, ForwardB;
	logic        MemWrite, RegWriteW;
	logic [4:0] RdW, Rs1D, Rs2D;
	
	// instantiate device to be tested
	top dut(clk, reset, WriteData, DataAdr, ReadData, InstrF, pcF, MemWrite, StallF, Rd1D, Rd2D, ImmExtD, ResultW, ForwardA, ForwardB, ResultSrcW, RegWriteW, RdW,
				Rs1D, Rs2D);
	
	// initialize test
	initial begin
	
		reset <= 1; #22; reset <= 0;
	
	end
	// generate clock to sequence tests
	
	always
	
	begin
	
		clk <= 1; #5; clk <= 0; # 5;
		
	end
		// check results
		
	always @(negedge clk) begin
	
		if(MemWrite) begin
			if(DataAdr === 100 & WriteData === 25) begin
				$display("Simulation succeeded");
				$stop;
			end 
			else if (DataAdr !== 96) begin
				$display("Simulation failed");
				$stop;
			end
	
	end
	
	end
endmodule


module tb_fetch();
	logic clk;
	logic reset;
	logic PCSrc;
	logic StallF;
	logic [31:0] PCTarget, pc, PCPlus4;
	
	fetch_unit dut(clk, reset, PCSrc, StallF, PCTarget, pc, PCPlus4);
	
	initial begin
		reset <= 1; #10; reset <= 0;
		PCSrc <= 0;
		
		repeat(4) begin
			$display("PC: %h", pc);
			#10;
		end
		
		PCSrc <= 1;
		PCTarget <= 32'h00000024;
		#10;
		
		PCSrc <= 0;
		repeat(4) begin
			$display("PC: %h", pc);
			#10;
		end
		$stop;
	end

	
	always
		begin
			clk <= 1; #5; clk <= 0; # 5;
		end
	
endmodule

module tb_test();

	logic [31:0] PCPlus4D, PCPlus4F, PCPlus4E;
	logic        clk;
	
	initial begin
		PCPlus4F <= 31'h3333_3333;
		PCPlus4D <= 31'h0000_0022;
		PCPlus4E <= 31'hB00B_B00B;
		#10;
		
		@(posedge clk) begin
			PCPlus4D <= PCPlus4F;
			PCPlus4E <= PCPlus4D;
		end
		#10;
		
		$stop;
		
	end
	
	always begin 
		clk <= 1; #5; clk <= 0; #5;
	end
	
	
	

endmodule 


module tb_controller;

	logic [6:0] op;
	logic [2:0] funct3;
	logic       funct7b5, Zero, clk, FlushE;
	logic [1:0] ResultSrcW;
	logic       MemWriteM, ResultSrcE0;
	logic       PCSrcE, ALUSrcE;
	logic       RegWriteW, RegWriteM;
	logic [1:0] ImmSrcD;
	logic [2:0] ALUControlE;
	logic reset;

	
	controller dut(op, funct3, funct7b5, Zero, clk, FlushE, ResultSrcW, MemWriteM, ResultSrcE0, PCSrcE, ALUSrcE, RegWriteW, RegWriteM, ImmSrcD, ALUControlE,reset);
	
	always begin clk <= 1; #5; clk <= 0; #5; end

	initial begin
	
		reset <= 1; #20; reset <= 0;

	end

endmodule



module tb_rfile;

	logic        clk, rw;
	logic [4:0]  addr1, addr2, wr_address;
	logic [31:0] data_in;
	logic [31:0] data1_out, data2_out;

	regfile dut(clk, rw, addr1, addr2, wr_address, data_in, data1_out, data2_out);

	always begin clk <= 1; #5; clk <= 0; #5; end
	
	initial begin
		wr_address <= 3;
		data_in <= 5;
		rw <= 1;
		
		addr1 <= 3;
		addr2 <= 4;

	end

endmodule 

