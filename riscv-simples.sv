
//-----------memorias

module memoria_dados(

	input  logic [31:0] endereco, dado_entrada,
	input  logic        clock, permitir_escrita,
	output logic        dado_saida

);

	logic [31:0] matriz[63:0]; // corta os primeiros dois bits para alinhamento de dados
	
	assign dado_saida = matriz[endereco[31:2]];
	
	always_ff @(posedge clock) 
		if (permitir_escrita) matriz[endereco[31:2]] <= dado_entrada;

endmodule 

module memoria_instrucoes(

	input  logic [31:0] endereco, 
	output logic        dado_saida

);

	logic [31:0] matriz[63:0]; // corta os primeiros dois bits para alinhamento de dados
	assign dado_saida = matriz[endereco[31:2]];
	
endmodule


//--------registradores

module registradores(

	input  logic [4:0]  endereco1_leitura, endereco2_leitura, endereco_escrita,
	input  logic [31:0] dado_entrada,
	input  logic        permitir_escrita, clock,
	output logic        dado_saida1, dado_saida2

);

	logic [31:0] matriz[31:0];

	always_ff @(posedge clock) 
		if(permitir_escrita && endereco_escrita != 'b0)
			matriz[endereco_escrita] <= dado_entrada;

	assign dado_saida1 = (endereco1_leitura != 'b0) ? matriz[endereco1_leitura] : 'b0;
	assign dado_saida2 = (endereco2_leitura != 'b0) ? matriz[endereco2_leitura] : 'b0;

endmodule

//------multiplexadores

module mux_2(

	input  logic [31:0] a,b,
	input  logic        controle,
	output logic        saida

);

	assign saida = controle ? b : a;

endmodule 

module mux_3(

	input  logic [31:0] a,b,c,
	input  logic [1:0]  controle,
	output logic        saida

);

	assign saida = (controle == 2'b00) ? a : (controle == 2'b01) ? b : c;

endmodule 

//------somador

module somador(

	input  logic [31:0] a,b,
	output logic        c

);

 assign c = a + b;

endmodule

//-------flipflop

module flop(

	input

);
