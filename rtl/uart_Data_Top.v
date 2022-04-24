
	module		data_Top(
		clk,
		reset);
		
		input		clk;
		input		reset;
		
		uart_Top(
		.clk,
		.reset,
		
		.rx,
		.test_Data,
		.button_Trig,
		.wr_Sig,
		
		.tx,
		.test1);
		
			reg		[7 : 0] rom_Data[7 : 0];
			reg		[2 : 0]	data_Cnt;
			always@(posedge sample_Clk or negedge reset)
				begin
					if(~reset)
						begin
							rom_Data[0] <= 8'h11;
							rom_Data[1] <= 8'h22;
							rom_Data[2] <= 8'h33;
							rom_Data[3] <= 8'h44;
							rom_Data[4] <= 8'h55;
							rom_Data[5] <= 8'h66;
							rom_Data[6] <= 8'h77;
							rom_Data[7] <= 8'h88;
							data_Cnt <= 1'b0;
						end
					else
						begin
							data_Cnt <= data_Cnt + 1'b1;
							wr_Sig <= 1'b1;
							test_Data <= rom_Data[data_Cnt];
						end
				end