
// --- Pipeline

// A fazer:

// Testes. Testbench está retornando muitos valores indefinidos. Possíveis erros nas ligações entre módulos?
/*
Suposições:

* todos os módulos estão funcionando perfeitamente bem sozinhos, mas não foram testados isoladamente:
	1 - datapath
	2 - unidade de controle com a pipeline (sem pipeline estava funcionando)
	3 - unidade de execução

- datapath está em descompasso com a unidade de controle?
- datapath possui os módulos com ligações erradas?
- checar novamente a ordem de execução de non-blocking assignments



*/


//-------------somador--------------/

module adder(
	input  [31:0] a, b,
	output [31:0] y
);
	assign y = a + b;
endmodule

//------------registeel-----------------//

module flopr #(parameter WIDTH = 8) (
	input  logic             clk, reset,
	input  logic [WIDTH-1:0] d,
	output logic [WIDTH-1:0] q
);
	always_ff @(posedge clk, posedge reset)
		if (reset) q <= 0;
		else q <= d;
endmodule

module flopenr #(parameter WIDTH = 8) (
	input  logic             clk, reset, en,
	input  logic [WIDTH-1:0] d,
	output logic [WIDTH-1:0] q
);
	always_ff @(posedge clk, posedge reset)
		if (reset) q <= 0;
		else if (en) q <= d;
endmodule

//-------------------MUX----------------------//

module mux2 #(parameter WIDTH = 8) (
	input  logic [WIDTH-1:0] d0, d1,
	input  logic             s,
	output logic [WIDTH-1:0] y
);
	assign y = s ? d1 : d0;
endmodule

module mux3 #(parameter WIDTH = 8) (
	input  logic [WIDTH-1:0] d0, d1, d2,
	input  logic [1:0]       s,
	output logic [WIDTH-1:0] y
);
	assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule

//----------------ULA---------------------//

module alu(
	input  logic  [31:0] a, b,
	input  logic  [2:0]  alu_control,
	output logic  [31:0] result,
	output logic         zero
);
	wire [32:0] result_ext;
	assign result_ext = a + b;
	assign zero = (a + b) == 0 ? 1'b1 : 1'b0;
	
	always_comb begin
		case (alu_control)
			3'b000: result = a + b;
			3'b001: result = a - b;
			3'b101: result = a < b ? 1'b1 : 0;
			3'b011: result = a | b;
			3'b010: result = a & b;
			default: result = 32'b0;
		endcase
	end
endmodule


//---------regigigas file---------------//

module regfile (
	input  logic        clk, rw,
	input  logic [4:0]  addr1, addr2, wr_address,
	input  logic [31:0] data_in, 
	output logic [31:0] data1_out, data2_out
);
	logic [31:0] regs[31:0]; 
	
	always_ff @(negedge clk) 
		if (rw) regs[wr_address] <= data_in;

	assign data1_out = addr1 == 'b0 ? 'b0 : regs[addr1];
	assign data2_out = addr2 == 'b0 ? 'b0 : regs[addr2];
endmodule

//----------------------estendedor-----------------//

module extend(
	input  logic [31:7] instr,
	input  logic [1:0]  immsrc,
	output logic [31:0] immext
);
	always_comb
		case (immsrc)
			2'b00: immext = {{20{instr[31]}}, instr[31:20]};
			2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
			2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
			2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
			default: immext = 32'bx;
		endcase
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////

// para lidar com hazards

module hazard_unit(
	input  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
	input  logic       PcSrcE, ResultSrcE0, RegWriteM, RegWriteW,
	output logic       StallF, StallD, FlushD, FlushE,
	output logic [1:0] ForwardA, ForwardB

);
	logic lwstall;
	
	always_comb begin
	
		// caso o registrador fonte da operação na fase de execução seja o mesmo
		// que o registrador destino na fase de memory ou writeback,
		// podemos usar diretamente o valor das fases seguintes
		
		if(((Rs1E == RdM) && RegWriteM) && (Rs1E != 0)) ForwardA = 2'b10;
		else if(((Rs1E == RdW) && RegWriteW) && (Rs1E != 0)) ForwardA = 2'b01;
		else ForwardA = 2'b00;
		
		if(((Rs2E == RdM) && RegWriteM) && (Rs2E != 0)) ForwardB = 2'b10;
		else if(((Rs2E == RdW) && RegWriteW) && (Rs2E != 0)) ForwardB = 2'b01;
		else ForwardB = 2'b00;
	
		// no caso de load word, é necessário ter uma distância de duas etapas
		// da pipeline entre lw e a instrução que usará o valor guardado no rf
		// por isso, é necessário um stall quando lw está em exec e uma instrução no decode
		
		lwstall = ResultSrcE0 && ((Rs1D == RdE) || (Rs2D == RdE));
		StallF = lwstall;
		StallD = lwstall;
		
		// quando há uma instrução de branch, não se sabe até o fim da execução da instrução se ele
		// será tomado ou não. por isso, deve-se escolher se foi tomado ou não no começo da instrução
		// e limpar a pipeline caso a escolha esteja errada
		// nesse caso, para simplificação, sempre vamos decidir que não foi tomado.
		
		FlushD = PcSrcE;
		FlushE = lwstall || PcSrcE;
		
	end

endmodule


//----------------control unit----------------//

// junta os módulos de decoding

module controller(
	input  logic [6:0] op,
	input  logic [2:0] funct3,
	input  logic       funct7b5, Zero, clk, FlushE,
	output logic [1:0] ResultSrcW,
	output logic       MemWriteM, ResultSrcE0,
	output logic       PCSrcE, ALUSrcE,
	output logic       RegWriteW, RegWriteM,
	output logic [1:0] ImmSrcD,
	output logic [2:0] ALUControlE,
	
	input logic reset
);
	logic [1:0] ALUOp, ResultSrcD, ResultSrcM, ResultSrcE;
	logic       Branch, Jump, RegWriteD, RegWriteE;
	logic       MemWriteD, MemWriteE;
	logic			JumpD, JumpE;
	logic			BranchD, BranchE;
	logic [2:0] ALUControlD;
	logic			ALUSrcD;
	
	assign ResultSrcE0 = ResultSrcE[0]; // vai para hazard_unit
	
	maindec md(op, ResultSrcD, MemWriteD, BranchD, ALUSrcD, RegWriteD, JumpD, ImmSrcD, ALUOp); // decoder principal
	
	aludec ad(op[5], funct3, funct7b5, ALUOp, ALUControlD); // decoder da ula, que depende do aluop do decoder principal
	
	always_ff @(posedge clk) begin
		
		// decode -> execute -> memory
		
		if(FlushE | reset) begin
		
			RegWriteE <= 0;
			ResultSrcE <= 0;
			MemWriteE <= 0;
			JumpE <= 0;
			BranchE <= 0;
			ALUControlE <= 0;
			ALUSrcE <= 0;
			
		end
		else begin
		
			RegWriteE <= RegWriteD;
			ResultSrcE <= ResultSrcD;
			MemWriteE <= MemWriteD;
			JumpE <= JumpD;
			BranchE <= BranchD;
			ALUControlE <= ALUControlD;
			ALUSrcE <= ALUSrcD;
		
		end
		
		if(reset) begin
		
			RegWriteM <= 0;
			ResultSrcM <= 0;
			MemWriteM <= 0;
			
			RegWriteW <= 0;
			ResultSrcW <= 0;
		
		end 
		else begin
		
			RegWriteM <= RegWriteE;
			ResultSrcM <= ResultSrcE;
			MemWriteM <= MemWriteE;
			
			RegWriteW <= RegWriteM;
			ResultSrcW <= ResultSrcM;
		
		end
	end
	
	assign PCSrcE = (BranchE & Zero) | JumpE;
endmodule

// decoder principal

module maindec(
	input  logic [6:0] op,
	output logic [1:0] ResultSrc,
	output logic       MemWrite,
	output logic       Branch, ALUSrc,
	output logic       RegWrite, Jump,
	output logic [1:0] ImmSrc,
	output logic [1:0] ALUOp
);
	logic [10:0] controls;
	assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;
	always_comb
		case (op)
			7'b0000011: controls = 11'b1_00_1_0_01_0_00_0;
			7'b0100011: controls = 11'b0_01_1_1_00_0_00_0;
			7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0;
			7'b1100011: controls = 11'b0_10_0_0_00_1_01_0;
			7'b0010011: controls = 11'b1_00_1_0_00_0_10_0;
			7'b1101111: controls = 11'b1_11_0_0_10_0_00_1;
			default: controls = 11'b0_xx_0_0_00_0_xx_0;
		endcase
endmodule


// decoder da ula, depende de aluop do decoder principal

module aludec(
	input logic        op_bit,
	input logic  [2:0] funct3,
	input logic        funct7b5,
	input logic  [1:0] alu_op,
	output logic [2:0] alu_control
);
	logic RtypeSub;
	assign RtypeSub = funct7b5 & op_bit;
	always_comb
		case (alu_op)
			2'b00: alu_control = 3'b000;
			2'b01: alu_control = 3'b001;
			default: case (funct3)
				3'b000: alu_control = RtypeSub ? 3'b001 : 3'b000;
				3'b010: alu_control = 3'b101;
				3'b110: alu_control = 3'b011;
				3'b111: alu_control = 3'b010;
				default: alu_control = 3'bxxx;
			endcase
		endcase
endmodule


// unidade para buscar instrução e computar o próximo valor do program counter

module fetch_unit(
	input  logic        clk, reset, PcSrc, StallF,
	input  logic [31:0] PCTarget,
	output logic [31:0] pc, PCPlus4

);

	logic [31:0] PCNext;
	
	mux2 #(32) pcmux(PCPlus4, PCTarget, PcSrc, PCNext); // mux proximo PC (se branch ou não)
	
	flopenr #(32) pcreg(clk, reset, !StallF, PCNext, pc); // PC
	
	adder pcadd4(pc, 32'd4, PCPlus4); // somador para pc (sem branch)

endmodule 

// unidade para busucar valores no register file e fazer a extensão do imediato enquanto o controlador faz o decode da instrução


module rf_unit(
	input  logic        RegWrite, clk,
	input  logic [1:0]  ImmSrc,
	input  logic [31:0] Result,
	output logic [31:0] Rd1, Rd2, ImmExt,
	input  logic [4:0]  Rd, Rs1D, Rs2D,
	input  logic [24:0] Imm

);
	
	regfile rf(clk, RegWrite, Rs1D, Rs2D, Rd, Result, Rd1, Rd2); // register file
	
	extend ext(Imm, ImmSrc, ImmExt); // extend

endmodule 

// unidade para gerenciar o datapath da execução. computa o branch do program counter.

module execute_unit(
	input  logic        ALUSrc,
	input  logic [1:0]  ForwardA, ForwardB,
	input  logic [2:0]  ALUControl,
	input  logic [31:0] Rd1, Rd2, pc, ImmExt, ALUResultM, ResultW,
	output logic [31:0] ALUResult, WriteData, PCTarget,
	output logic        Zero

);

	logic [31:0] SrcA, SrcB;
	

	alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero); // ula
	
	adder pcaddbranch(pc, ImmExt, PCTarget); // valor do branch para pc
	
	// escolhem o valor de entrada da ula caso utilize algum valor que está nos próximos 2 estágios
	// (memory ou writeback) sem precisar fazer o stall da pipeline.
	
	mux3 #(32) scrAhazard(Rd1, ResultW, ALUResultM, ForwardA, SrcA); 
	
	mux3 #(32) lerolerohazard(Rd2, ResultW, ALUResultM, ForwardB, WriteData); // não consigo mudar o nome porque dá erro no quartus?
	
	//
	
	mux2 #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB); // origem de b na ula

endmodule

// com certeza, aqui está o erro

module datapath(
	input  logic        clk, reset,
	
	// do decoder
	input  logic [1:0]  ResultSrcW,
	input  logic        PCSrcE, ALUSrcE,
	input  logic        RegWriteW,
	input  logic [1:0]  ImmSrcD,
	input  logic [2:0]  ALUControlE,
	
	
	//instr mem
	input  logic [31:0] InstrF,
	output logic [31:0] pcF,
	
	//data mem
	input  logic [31:0] ReadDataM,
	output logic [31:0] ALUResultM, WriteDataM,
	
	// para decoder
	output logic [31:0] InstrD,
	output logic        ZeroE,
	
	// hazard unit
	input  logic [1:0]  ForwardA, ForwardB,
	input  logic        StallF, StallD, FlushD, FlushE,
	output logic [4:0]  Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
	
	// debug
	
	output logic [31:0] Rd1D, Rd2D, ImmExtD, ResultW
);

	logic [31:0] PCPlus4F;
	logic [31:0] pcD, PCPlus4D/*, ImmExtD, Rd1D, Rd2D*/;
	logic [31:0] PCTargetE, Rd1E, Rd2E, ImmExtE, pcE, ALUResultE, WriteDataE, PCPlus4E;
	logic [31:0] PCPlus4M;
	logic [31:0] /*ResultW,*/ ReadDataW, ALUResultW, PCPlus4W;
	logic [24:0] Imm;
	
	logic [4:0]  RdD;
	
	assign Rs1D = InstrD[19:15];
	assign Rs2D = InstrD[24:20];
	assign RdD = InstrD[11:7];
	assign Imm = InstrD[31:7];
	
	
	// fetch
	
	fetch_unit fetch_unit(clk, reset, PCSrcE, StallF, PCTargetE, pcF, PCPlus4F);
	
	always_ff @(posedge clk) begin
		
		if (FlushD || reset) begin
			InstrD <= 0;
			pcD <= 0;
			PCPlus4D <= 0;
		end
		else if(!StallD) begin
			InstrD <= InstrF;
			pcD <= pcF;
			PCPlus4D <= PCPlus4F;
		end
		
	end
	
	
	// decode		
	
	rf_unit rf_unit(RegWriteW, clk, ImmSrcD, ResultW, Rd1D, Rd2D, ImmExtD, RdW, Rs1D, Rs2D, Imm);
	
	always @(posedge clk) begin
	
		if(FlushE || reset) begin
			pcE <= 0;
			Rd1E <= 0;
			Rd2E <= 0;
			Rs1E <= 0;
			Rs2E <= 0;
			RdE <= 0;
			ImmExtE <= 0;
			PCPlus4E <= 0;
		end
		else begin
			pcE <= pcD;
			Rd1E <= Rd1D;
			Rd2E <= Rd2D;
			Rs1E <= Rs1D;
			Rs2E <= Rs2D;
			RdE <= RdD;
			ImmExtE <= ImmExtD;
			PCPlus4E <= PCPlus4D;
		end
	end
	
	// execute e wb
	
	execute_unit ex_unit(ALUSrcE, ForwardA, ForwardB, ALUControlE, Rd1E, Rd2E, pcE, ImmExtE, ALUResultM, ResultW, ALUResultE, WriteDataE, PCTargetE, ZeroE);
	
	always @(posedge clk) begin
		
		if (reset) begin
	
			ALUResultM <= 0;
			WriteDataM <= 0;
			RdM <= 0;
			PCPlus4M <= 0;
		
			ALUResultW <= 0;
			ReadDataW <= 0;
			RdW <= 0;
			PCPlus4W <= 0;
	
		end
		else begin
		
			ALUResultM <= ALUResultE;
			WriteDataM <= WriteDataE;
			RdM <= RdE;
			PCPlus4M <= PCPlus4E;
		
			ALUResultW <= ALUResultM;
			ReadDataW <= ReadDataM;
			RdW <= RdM;
			PCPlus4W <= PCPlus4M;
			
		end
	end
	
	
	
	mux3 #(32) writeback_mux(ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, ResultW);
	
	
endmodule

//-------------------------core-----------------------------//

module rvpipeline(
	input  logic        clk, reset,
	
	// instr mem
	output logic [31:0] pcF,
	input  logic [31:0] InstrF,
	
	// data mem
	output logic        MemWriteM,
	output logic [31:0] ALUResultM, WriteDataM,
	input  logic [31:0] ReadDataM,
	
	// debug
	
	output logic StallF,
	output logic [31:0] Rd1D, Rd2D, ImmExtD, ResultW,
	output logic [1:0]  ForwardA, ForwardB, ResultSrcW,
	output logic RegWriteW,
	output logic [4:0] RdW, Rs1D, Rs2D
);

	logic        ALUSrcE, /*RegWriteW, */RegWriteM, ZeroE, PCSrcE, ResultSrcE0;
	logic			 /*StallF,*/ StallD, FlushD, FlushE;
	logic [1:0]  /*ResultSrcW,*/ ImmSrcD/*, ForwardA, ForwardB*/;
	logic [2:0]  ALUControlE;
	logic [4:0]  /*Rs1D, Rs2D,*/ Rs1E, Rs2E, RdE, RdM/*, RdW*/;
	logic [31:0] InstrD;
	
	controller c(InstrD[6:0], InstrD[14:12], InstrD[30], ZeroE, clk, FlushE, ResultSrcW, MemWriteM, ResultSrcE0, PCSrcE, ALUSrcE, RegWriteW, RegWriteM, ImmSrcD, ALUControlE, reset);
	
	datapath dp(clk, reset, ResultSrcW, PCSrcE, ALUSrcE, RegWriteW, ImmSrcD, ALUControlE, InstrF, pcF, ReadDataM, ALUResultM, WriteDataM, InstrD, ZeroE,
					ForwardA, ForwardB, StallF, StallD, FlushD, FlushE, Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW, Rd1D, Rd2D, ImmExtD, ResultW);
	
	hazard_unit hu(Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW, PCSrcE, ResultSrcE0, RegWriteM, RegWriteW,StallF, StallD, FlushD, FlushE, ForwardA, ForwardB);
	
endmodule

//----------------core e memorias---------------------//

module top (
	input  logic        clk, reset,
	output logic [31:0] WriteDataM, ALUResultM, ReadDataM, InstrF, pcF,
	output logic        MemWriteM,
	output logic StallF,
	output logic [31:0] Rd1D, Rd2D, ImmExtD, ResultW,
	output logic [1:0]  ForwardA, ForwardB, ResultSrcW,
	output logic RegWriteW,
	output logic [4:0] RdW, Rs1D, Rs2D
);

	
	rvpipeline rvp(clk, reset, pcF, InstrF, MemWriteM,	ALUResultM, WriteDataM, ReadDataM, StallF, Rd1D, Rd2D, ImmExtD, ResultW, ForwardA, ForwardB, ResultSrcW, RegWriteW, RdW, Rs1D, Rs2D);
	
	imem imem(pcF, InstrF);
	
	dmem dmem(clk, MemWriteM, ALUResultM, WriteDataM, ReadDataM);
	
endmodule

//------------------memorias--------------------//

module imem(
	input  logic [31:0] a,
	output logic [31:0] rd
);
	logic [31:0] RAM[63:0];
	
	initial
		$readmemh("C:/github/IC-Single-core/riscvtest.txt",RAM);
	assign rd = RAM[a[31:2]]; // word aligned
	
endmodule

module dmem(
	input  logic        clk, we,
	input  logic [31:0] a, wd,
	output logic [31:0] rd
);
	logic [31:0] RAM[63:0];
	
	assign rd = RAM[a[31:2]]; // word aligned
	
	always_ff @(posedge clk)
	if (we) RAM[a[31:2]] <= wd;
	
endmodule
