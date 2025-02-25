module tb_rvpipeline();
	logic clk;
	logic reset;
	logic [31:0] WriteData, DataAdr, ReadData, InstrF, pcF;
	logic MemWrite;
	
	// instantiate device to be tested
	top dut(clk, reset, WriteData, DataAdr, ReadData, InstrF, pcF, MemWrite);
	
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
	logic [31:0] PCTarget, pc, PCPlus4;
	
	fetch_unit dut(clk, reset, PCSrc, PCTarget, pc, PCPlus4);
	
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