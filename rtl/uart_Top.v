`include "./uart_Define.v"
	module uart_Top(
		clk,
		reset,
		
		rx,
		test_Data,
		button_Trig,
		wr_Sig,
		
		tx,
		sig_Empty,
		sig_Full);
		
		
		input			clk;
		input			reset;
		
		input			rx;
		input	[7 : 0]	test_Data;
		input			button_Trig;
		input			wr_Sig;
		
		output			tx;
		output			sig_Empty;
		output			sig_Full;
		
		
		wire			sample_Clk;
		wire			x16_Sample_Clk;
		
		wire		[7 : 0]	rx_Data;
		wire				rx_Done;
		wire				tx_Start;
		wire		[7 : 0]	buffer_Data;
		
		`ifdef	using_Rx
			uart_Receiver Receiver(
			.d_Clk(x16_Sample_Clk),
			.reset(reset),
			.rx(rx),
			
			.rx_Data(rx_Data),
			.rx_Done(rx_Done));
			////////////////////
			uart_Transmitter Transmitter(
			.sample_Clk(sample_Clk),
			.reset(reset),
			.tx_Data(rx_Data),
			.tx_Start(rx_Done),
			
			.tx(tx));
			
		`elsif	Using_Buffer
			uart_Buffer #(.BUFFER_DEPTH(8),
						   .BUFFER_WIDTH(8),
						   .POINTER_SIZE(3),
						   .fifo_Enable(1))
				Buffer(
				.sample_Clk(sample_Clk),
				.reset(reset),
				.button_Trig(button_Trig),
				
				.wr_Sig(wr_Sig),
				.test_Data(test_Data),
				
				.tx_Start(tx_Start),
				.tx_Data(buffer_Data),
				.sig_Full(sig_Full),
				.sig_Empty(sig_Empty));
			//////////////////////////
			uart_Transmitter Transmitter(
				.sample_Clk(sample_Clk),
				.reset(reset),
				.tx_Data(buffer_Data),
				.tx_Start(tx_Start),
				.tx(tx));
		`endif
		
		uart_Sampler #(.UBRR(2604), 
					   .x16_UBRR(162), 
					   .UBRR_BIT(12),
					   .x16_UBRR_BIT(8))
		Sampler (
		.clk(clk),
		.reset(reset),
		
		.o_Sample_Clk(sample_Clk),
		.o_X16_Sample_Clk(x16_Sample_Clk));
		
		
		endmodule