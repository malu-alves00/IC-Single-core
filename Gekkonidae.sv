
//-------------------MUX----------------------//

module mux_2to1 (
	input  logic [31:0] a,b,
	input  logic 		  control,
	output logic [31:0] out
);

always_comb begin

case(control)
	1'b0: out = a;
	1'b1: out = b;
	default: out = a;
	
endcase
end

endmodule


//-----------------------ULA---------------------------------//
// sem implementar overflow aritmético


module alu(
	input  logic  [31:0] a,b,
	input  logic  [2:0]  alu_control,
	output logic  [31:0] result,
	output logic         overflow,
	output logic         zero
);

	wire [32:0] result_ext;
	
	assign result_ext = a + b;
	assign zero = (a+b) == 0 ? 1'b1 : 1'b0;
	
	assign overflow = result_ext[32];
	
	always_comb begin
	
	case(alu_control)
	
		3'b0: begin
					result = a + b;
				end
				
		default: result = 32'b0;
	endcase
	
	end

endmodule


// ------------------- registradores ------------------------//
// PASSOU NOS TESTES
// CHECADO

// 32x32, como padrão para RISC-V
// read=0 write=1
// registrador x0 sempre retorna 0
module register_file #(
	parameter DATA_WIDTH = 32, // 32-bits
	parameter NUM_REGS   = 32, // 32 registradores
	parameter INDEX_WIDTH = $clog2(NUM_REGS)
)(
	input  logic                     clk,
	input  logic                     rw, 
	input  logic [INDEX_WIDTH-1:0]   addr1, 
	input  logic [INDEX_WIDTH-1:0]   addr2, 
	input  logic [INDEX_WIDTH-1:0]   wr_address, 
	input  logic [DATA_WIDTH-1:0]    data_in, 
	output logic [DATA_WIDTH-1:0]    data1_out,
	output logic [DATA_WIDTH-1:0]    data2_out
);

	logic [DATA_WIDTH-1:0] regs[NUM_REGS]; 
	
	always_ff @(posedge clk) begin
		if(rw & (wr_address != 'b0)) begin
			regs[wr_address] <= data_in;
		end
	end
	
	assign data1_out = !rw & addr1 == 'b0 ? 'b0 :
							 !rw ? regs[addr1] : 'hz;
	assign data2_out = !rw & addr2 == 'b0 ? 'b0 :
							 !rw ? regs[addr2] : 'hz;
endmodule


//-------------PC-------------------------------------------//
// PASSOU NO TESTE
// CHECADO

module program_counter #(
	parameter INSTR_WIDTH = 32
)(
	input  logic [15:0] PC_next,
	input  logic        reset, clk,
	output logic [15:0] PC_state
	
);

always_ff @(posedge clk) begin

	if(reset) PC_state = 16'b0;
	
	else begin
	
		PC_state <= PC_next;
		
	end

end

endmodule

//-----------------somador pc-------------------------//
/*
module pc_sum (
	input  logic [15:0] PC_value,
	input  logic [15:0] num,
	output logic [15:0] PC_sum
	
);

always_comb begin

	PC_sum = PC_value + num;

end

endmodule
*/

//--------------NAO LIGO SIGMA SIGMA BOY----------------//
// se alguma coisa der errado, se referir a essa parte sigma

module pc_sum (
	input  logic [15:0] PC_value,
	input  logic [31:0] imm_ext,
	input  logic        PC_src,
	output logic [15:0] PC_sum
	
);

always_comb begin

	PC_sum = PC_src == 0 ? PC_value + 4 : PC_value + imm_ext;

end

endmodule

//----------------INSTR MEM----------------------//
// PASSOU NO TESTE

module instruction_memory #(
	parameter DATA_WIDTH = 32,
	parameter DATA_DEPTH = 128, // aqui, só podemos ter endereço [7:0] porque não há espaço na placa. Depois ver de adicionar memória externa.
	parameter INDEX_WIDTH = $clog2(DATA_DEPTH)
)(

	input  logic [INDEX_WIDTH-1:0] address,
	output logic [DATA_WIDTH-1:0]  data_out

);

	logic [DATA_WIDTH-1:0] memory[DATA_DEPTH];
	
	assign data_out = memory[address];

endmodule

//---------------DATA MEM-----------------------------//
// PASSOU NO TESTE

module data_memory #(
	parameter DATA_WIDTH = 32,
	parameter DATA_DEPTH = 128, // aqui, só podemos ter endereço [7:0] porque não há espaço na placa. Depois ver de adicionar memória externa.
	parameter INDEX_WIDTH = $clog2(DATA_DEPTH)
)(

	input  logic [INDEX_WIDTH-1:0] address,
	input  logic [DATA_WIDTH-1:0]  write_data,
	input  logic                   clk, wr,
	output logic [DATA_WIDTH-1:0]  read_data

);

	logic [DATA_WIDTH-1:0] memory[DATA_DEPTH];
	
	always_ff @(posedge clk) begin
	
		if(wr) memory[address] <= write_data;
		
		else read_data <= memory[address];
		
	end
	
endmodule


//--------------------extender----------------------------//
// CHECADO

module extend_unit (
	input  logic [24:0] src,
	input  logic [1:0]  imm_src,
	output logic [31:0] imm_ext

);

// falta U type. vai fazer tanta falta assim?

	always_comb begin
		
		case(imm_src)	
		
			2'b00: imm_ext = {{20{src[24]}},src[24:13]}; // I-type
			2'b01: imm_ext = {{20{src[24]}},src[24:18],src[4:0]}; // S-type
			2'b10: imm_ext = {{20{src[24]}},src[0],src[23:18],src[4:1],1'b0}; // branch offset
			2'b11: imm_ext = {{12{src[24]}},src[12:8],src[13],src[23:14], 1'b0}; // J-type
			
			default: imm_ext = 32'b0;
		
		endcase
	end
	
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------decoder--------------------------------//

/* ORDEM:

	pc_src (branch && zero flag) - result_src - mem_write - alu_src - imm_src[1:0] - reg_write ---- alu_control[2:0]


*/


module main_fsm (
	input  logic [6:0] opcode,
	input  logic [3:0] funct3,
	input  logic [7:0] funct7,
	input  logic 	 	 zero,
	output logic [1:0] alu_op,
	output logic [6:0] control_word
);

always_comb begin

	case(opcode)
		7'b0000011: begin
			control_word = 7'b0101001;
			alu_op = 2'b00;
		end
		
		7'b0100011: begin
			control_word = 7'b0x11010;
			alu_op = 2'b00;
		end
		
end
endmodule 



////////////////////////////////////////////////////////////////////////////////////////////////////////


//--------₊✩‧₊˚౨ৎ˚₊✩‧₊----core-----₊✩‧₊˚౨ৎ˚₊✩‧₊--------//
// cavalo xbox? 



module Gekkonidae (

input logic clk,
input logic reset

);

	// sugestão: colocar wires de controle como maiusculo, wires de dados como minusculo

	// datapath controle =-=-=-=-=-=-=-
	
	wire pc_src, reg_write, alu_src, zero, mem_write, result_src;
	wire [1:0] imm_src;
	wire [2:0] alu_control;

	// datapath dados =-=-=-=-=-=-=-
	
	wire [15:0] pc, pc_next, pc_mais_quatro, pc_target;
	wire [31:0] instr, result, out_reg_1, out_reg_2, imm_ext, src_b, alu_result, read_data;
	
	

	/*
	// selecionar se pega o branch
	mux_2to1 branch_taken_or_not(
									.a(pc_mais_quatro),
									.b(pc_target),
									.control(pc_src),
									.out(pc_next)
								);
	*/ // se der erro na parte sigma, descomentar isso aqui
	

	
	pc_sum pc_sum_four(
							  .PC_value(pc),
							  .imm_ext(imm_ext),
							  .PC_src(pc_src),
							  .PC_sum(pc_next)
							);
	
	// program counter
	program_counter program_counter(
												.PC_next(pc_next),
												.reset(reset),
												.clk(clk),
												.PC_state(pc)
											  );
	
	
	// instruction memory
	instruction_memory instruction_memory(
														.address(pc[7:0]),
														.data_out(instr)
													 );
				  

	// register file
	register_file register_file(
										 .clk(clk),
										 .rw(reg_write),
										 .addr1(instr[19:15]),
										 .addr2(instr[24:20]),
										 .wr_address(instr[11:7]),
										 .data_in(result),
										 .data1_out(out_reg_1),
										 .data2_out(out_reg_2)
										);
	


	// extend to 32-bits
	extend_unit extend_unit(
									.src(instr[31:7]),
									.imm_src(imm_src),
									.imm_ext(imm_ext)
	
								  );
	
	
	// selecionar de onde vem operando B da ULA
	mux_2to1 sel_src_b(
							 .a(out_reg_2),
							 .b(imm_ext),
							 .control(alu_src),
							 .out(src_b)
							);
							

	// a grande ula
	alu alu(
			  .a(out_reg_1),
			  .b(src_b),
			  .alu_control(alu_control),
			  .result(alu_result),
			  .zero(zero)
			 );
	
	// data memory
	data_memory data_memory(
									.address(alu_result[7:0]),
									.write_data(out_reg_2),
									.clk(clk),
									.wr(mem_write),
									.read_data(read_data)
								  );
								  
	// select write register source
	mux_2to1 sel_reg_wr(
							 .a(alu_result),
							 .b(read_data),
							 .control(result_src),
							 .out(result)
							);
								  

endmodule 




/*
miau?! parece que você chegou no fim do código!

	 ╱|、
	(˚。 7  
	|`  〵          
	じしˍ, )ノ


*/