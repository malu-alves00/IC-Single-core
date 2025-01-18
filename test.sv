module test (
	input  logic [3:0] code,
	output logic [3:0] word
);

	assign word = code;

endmodule

module test_concat(
	input  logic [3:0] code,
	output logic       a,b,c,d
);

 test test(
				.code(code),
				.word({a,b,c,d})
			 );



endmodule 