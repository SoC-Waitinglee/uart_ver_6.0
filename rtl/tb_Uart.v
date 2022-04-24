`include "./uart_Define.v"
	module		tb_Uart();
	
	reg		clk;
	reg		reset;
	
	reg		rx;
	reg		[7 : 0] test_Data;
	
	reg			button_Trig;
	reg			wr_Sig;
	reg			sample_Clk;
	reg			en;
	wire		tx;
	reg		[7 : 0]	data[7 : 0];
	integer i,j;
	
	initial	
		begin
			clk = 1'b0;
			reset = 1'b1;
			rx = 1'b1;
			test_Data = 1'b0;
			wr_Sig = 1'b0;
			sample_Clk = 1'b0;
		end

			
	always #5 clk = ~clk;
	always #52083 sample_Clk = ~sample_Clk;
	
	// reset control
	initial
		begin
			#200 reset = 1'b0;
			#20 reset = 1'b1;
		end
	initial
			begin
				data[0] <= 8'h11;
				data[1] <= 8'h22;
				data[2] <= 8'h33;
				data[3] <= 8'h44;
				data[4] <= 8'h55;
				data[5] <= 8'h66;
				data[6] <= 8'h77;
				data[7] <= 8'h88;
			end
	initial
		begin
			#400 ;
			for(i = 0; i < 8; i = i + 1)
				begin
					rx = 1'b0; #52083;
					for(j = 0; j < 8; j = j + 1)
						begin
							rx = data[i][j]; #52083;
						end
					rx = 1'b1; #100000;
				end
		end
	`ifdef	using_RX
		// rx data control	
	
	`elsif Using_Buffer
	always@(posedge sample_Clk or negedge reset)
		begin
			if(~reset)
				en <= 1'b0;
			else
				en <= ~en;
		end
	
	always@(posedge sample_Clk)
		if(en)
			begin
				wr_Sig <= 1'b1;
				test_Data <= 8'h93;
			end
		else
			begin
				wr_Sig <= 1'b0;
				test_Data <= 1'b0;
			end
	always@(posedge sample_Clk or negedge reset)
		begin
			if(~reset)
				button_Trig <= 1'b1;
			else if(en)
				button_Trig <= 1'b0;
			else 
				button_Trig <= button_Trig;
		end
		
	`endif
	
	uart_Top Uart(
		.clk(clk),
		.reset(reset),
		
		.rx(rx),
		.test_Data(test_Data),
		.button_Trig(button_Trig),
		.wr_Sig(wr_Sig),
		
		.tx(tx));
		
	
	endmodule
	