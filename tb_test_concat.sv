module tb_test_concat;

	logic [3:0] code;
	logic       a,b,c,d;

	test test(
				.code(code),
				.word({a,b,c,d})
			 );
	
	initial begin
	
	code = 4'b0110;
	#10;
	
	$stop;
	end
	

endmodule 