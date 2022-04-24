`include "./uart_Define.v"
	//Input clk = 10Mhz(Period : 10ns)
	//Output sample_Clk = 19200bps
	//Output x16_Sample_Clk = 19200bps(Period : 52us)
	
	module	uart_Sampler(
		clk,
		reset,
		
		o_Sample_Clk,
		o_X16_Sample_Clk);
		
		
		input			clk;
		input			reset;
		
		output			o_Sample_Clk;
		output			o_X16_Sample_Clk;
		
		
		parameter		UBRR = 2604;
		parameter		x16_UBRR = 162;
		parameter		UBRR_BIT = 12;
		parameter		x16_UBRR_BIT = 8;
		
		reg		[UBRR_BIT - 1 : 0]			clk_Sample;
		reg		[x16_UBRR_BIT - 1 : 0]		x16_Clk_Sample;
		reg									sample_Reg;
		reg									x16_Sample_Reg;
		
		// clk_Sample
		always@(posedge clk or negedge reset)
			begin
				if(~reset)
					begin
						clk_Sample <= 1'b0;
						sample_Reg <= 1'b0;
					end
				else
					if(clk_Sample == UBRR - 1)
						begin
							clk_Sample <= 1'b0;
							sample_Reg <= ~sample_Reg;
						end
					else
						begin
							clk_Sample <= clk_Sample + 1'b1;
							sample_Reg <= sample_Reg;
						end
			end
						
		
		
		// x16_Clk_Sample
		always@(posedge clk or negedge reset)
			begin
				if(~reset)
					begin
						x16_Clk_Sample <= 1'b0;
						x16_Sample_Reg <= 1'b0;
					end
				else
					if(x16_Clk_Sample == x16_UBRR - 1)
						begin
							x16_Clk_Sample <= 1'b0;
							x16_Sample_Reg <= ~x16_Sample_Reg;
						end
					else
						begin
							x16_Clk_Sample <= x16_Clk_Sample + 1'b1;
							x16_Sample_Reg <= x16_Sample_Reg;
						end
			end
			
		assign		o_Sample_Clk = sample_Reg;
		assign		o_X16_Sample_Clk = x16_Sample_Reg;
		
		endmodule
		
		
		