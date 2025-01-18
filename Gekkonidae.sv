
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
// sem implementar overflow 


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
				
		3'b001: result = a - b;
		
		3'b101: result = 1'b1 ? a < b : 0;
		
		3'b011: result = a | b;
		
		3'b010: result = a & b;
				
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
	
	assign data1_out = !rw && addr1 == 'b0 ? 'b0 :
							 !rw ? regs[addr1] : 'hz;
	assign data2_out = !rw && addr2 == 'b0 ? 'b0 :
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

//--------------NAO LIGO----------------//
// se alguma coisa der errado, se referir a essa parte e descomentar acima

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



module main_decoder (
	input  logic [6:0] opcode,
	output logic [1:0] alu_op,
	output logic [6:0] control_word
);



always_comb begin

	casez(opcode)
		7'b0000011: begin // lw
			control_word = 7'b0101001;
			alu_op = 2'b00;
		end
		
		7'b0100011: begin // sw
			control_word = 7'b0?11010; // eu não faço a minima ideia se é certo usar esse ?
			alu_op = 2'b00;
		end
		
		7'b0110011: begin // R-type
			control_word = 7'b0000??1;
			alu_op = 2'b10;
		end
		
		7'b1100011: begin // beq
			control_word = 7'b1?00100;
			alu_op = 2'b01;
		end
		
		7'b0010011: begin // addi
			control_word = 7'b0001001;
			alu_op = 2'b10;
		end
		
		default: begin
			control_word = 7'b0zzzzzz; // hihihihihi
			alu_op = 2'bzz;
		end
	endcase
	
end

endmodule

module alu_decoder(
	input  logic [2:0] funct3,
	input  logic       funct7,
	input  logic       op_bit,
	input  logic [1:0] alu_op,
	output logic [2:0] alu_control

);

logic [6:0] control_signal;

always_comb begin

control_signal = {alu_op, funct3, op_bit, funct7};
	
	// quando puder, separar melhor os tipos de instrução
	
	casez(control_signal)
		
		//7'b00?????: alu_control = 3'b000; // lw, sw
		//7'b01?????: alu_control = 3'b001; // beq
		
		// lw, sw, add
		7'b00?????, 7'b1000000, 7'b1000001, 7'b1000010: alu_control = 3'b000; // add
		
		// beq, sub
		7'b01?????, 7'b1000011: alu_control = 3'b001; // sub
		
		// slt
		7'b10010??: alu_control = 3'b101;
		
		// or
		7'b10110??: alu_control = 3'b011;
		
		//and
		7'b10111??: alu_control = 3'b010;
		
		
		
		default: alu_control = 3'bzzz;
	
	endcase


end

endmodule 

/* ORDEM:

	pc_src - alu_control[2:0] - branch - result_src - mem_write - alu_src - imm_src[1:0] - reg_write


*/


module full_decoder(

	input  logic        zero,
	input  logic [6:0]  op,
	input  logic [2:0]  funct3,
	input  logic 		  funct7,
	output logic [10:0] control_word


);

	logic [1:0] alu_op;

	main_decoder main_decoder(
										.opcode(op),
										.alu_op(alu_op),
										.control_word(control_word[6:0])
									  );
	
	alu_decoder alu_decoder(
									.funct3(funct3),
									.funct7(funct7),
									.op_bit(op[5]),
									.alu_op(alu_op),
									.alu_control(control_word[9:7])
									);
	assign control_word[10] = zero && control_word[6];

endmodule


////////////////////////////////////////////////////////////////////////////////////////////////////////


//--------₊✩‧₊˚౨ৎ˚₊✩‧₊----core-----₊✩‧₊˚౨ৎ˚₊✩‧₊--------//


module Gekkonidae (

input logic        clk,
input logic        reset,


// control word quentinho do decoder
output logic [10:0]  control_word_debug,

//output pc current state debug
output logic [15:0]  pc_value,

output logic [31:0]  out_reg_2_debug

);

	// sugestão: colocar wires de controle como maiusculo, wires de dados como minusculo
	
	// datapath controle =-=-=-=-=-=-=-
	
	wire pc_src, reg_write, alu_src, zero, mem_write, result_src, branch; // branch é temporário
	wire [1:0] imm_src, alu_op;
	wire [2:0] alu_control;

	

	// datapath dados =-=-=-=-=-=-=-
	
	wire [15:0] pc, pc_next, pc_mais_quatro, pc_target;
	wire [31:0] instr, result, out_reg_1, out_reg_2, imm_ext, src_b, alu_result, read_data;
	
	assign {pc_src, alu_control, branch, result_src, mem_write, alu_src, imm_src, reg_write} = control_word_debug;
	
	assign pc_value = pc;
	
	assign out_reg_2_debug = out_reg_2;
	
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
	
	
	instr_mem_rom instr_mem_rom(
											.address(pc[6:0]),
											.clock(clk),
											.q(instr)
	
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
			 
			 
	
	data_instr data_instr(
									.address(alu_result[6:0]),
									.clock(clk),
									.data(out_reg_2),
									.wren(mem_write),
									.q(read_data)
								);
	
								  
	// select write register source
	mux_2to1 sel_reg_wr(
							 .a(alu_result),
							 .b(read_data),
							 .control(result_src),
							 .out(result)
							);


	


	// control
	full_decoder full_decoder(
									  .zero(zero),
									  .op(instr[6:0]),
									  .funct3(instr[14:12]),
									  .funct7(instr[30]),
									  .control_word(control_word_debug) // essa é minha maior vigarice
									 );
	

endmodule 




/*
miau?! parece que você chegou no fim do código!

	 ╱|、
	(˚。 7  
	|`  〵          
	じしˍ, )ノ


*/


// 	NÃO TEM NADA AQUI EMBAIXO!!

/*

//----------------INSTR MEM----------------------//
// PASSOU NO TESTE
// mudar para a coisa certa após testes finais

module instruction_memory #(
	parameter DATA_WIDTH = 32,
	parameter DATA_DEPTH = 128, /// aqui, só podemos ter endereço [7:0] porque não há espaço (logicamente). Depois ver de colocar memória, mas tenho preguiça agora.
	parameter INDEX_WIDTH = $clog2(DATA_DEPTH)
)(

	input  logic [INDEX_WIDTH-1:0] address,
	input  logic [INDEX_WIDTH-1:0] address_in,
	input  logic                   clk, write_enable,
	input  logic [DATA_WIDTH-1:0]  data_in,
	output logic [DATA_WIDTH-1:0]  data_out, data_out_debug_instruction_memory

);

	logic [DATA_WIDTH-1:0] memory[DATA_DEPTH];
	
	assign data_out = memory[address];
	
	always_ff @(posedge clk) begin
	
		case(write_enable)
			0: data_out_debug_instruction_memory <= memory[address_in];
			1: memory[address_in] <= data_in;
		endcase

	end

endmodule





//---------------DATA MEM-----------------------------//
// PASSOU NO TESTE
// mudar para a coisa certa após testes finais

module data_memory #(
	parameter DATA_WIDTH = 32,
	parameter DATA_DEPTH = 128, // aqui, só podemos ter endereço [6:0] porque não há espaço (logicamente). Depois ver de colocar memória, mas tenho preguiça agora.
	parameter INDEX_WIDTH = $clog2(DATA_DEPTH) // log 2. matemática! um site muito legal me ensinou.
)(

	input  logic [INDEX_WIDTH-1:0] address,
	input  logic [DATA_WIDTH-1:0]  write_data,
	input  logic                   clk, wr,
	output logic [DATA_WIDTH-1:0]  read_data,
	
	
	input  logic [INDEX_WIDTH-1:0] address_debug,
	input  logic [DATA_WIDTH-1:0]  write_data_debug,
	input  logic                   enable_read_debug,
	output logic [DATA_WIDTH-1:0]  read_data_debug

);

	logic [DATA_WIDTH-1:0] memory[DATA_DEPTH];
	
	always_ff @(posedge clk) begin
	
		if(wr) memory[address] <= write_data;
		
		else read_data <= memory[address];
		
		// para testes muitíssimos importantes
		if(enable_read_debug) read_data_debug <= memory[address_debug];
		else 
			begin 
				read_data_debug <= 32'bz;
				memory[address_debug] <= write_data_debug;
			end
		
	end
	
endmodule


*/