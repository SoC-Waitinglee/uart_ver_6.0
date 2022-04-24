`include "./uart_Define.v"

	module uart_Receiver(
		d_Clk,
		reset,
		rx,
		
		rx_Data,
		rx_Done);
		
		
		input				d_Clk;
		input				reset;
		input				rx;
		
		output		[7 : 0] rx_Data;
		output				rx_Done;
		
		
		
		parameter	[1 : 0]		IDLE = 2'b00,
								START = 2'b01,
								RECEIVE = 2'b10,
								STOP = 2'b11;
		
		
		reg			[1 : 0]		rx_State;	// Receiver State 
		reg			[7 : 0]		rx_Shift;	// shift_Buffer 
		reg			[3 : 0]		data_Cnt;	// count receive data. when shift_Buffer stores rx bit 8 times, change state for STOP
		reg			[3 : 0]		sample_Cnt; // count d_Clk for sampling rx. when sample_Cnt show value of 8, stores to shift_Buffer at that time
		//FSM for Data Receive
		always@(posedge d_Clk or negedge reset)
			if(~reset)
				begin
					rx_State <= IDLE;
					rx_Shift <= 1'b0;
					data_Cnt <= 1'b0;
					sample_Cnt <= 1'b0;
				end
			else 
				begin
					case(rx_State)
						IDLE:
							if(rx == 1'b0)
								begin
									rx_State <= START;
								end
							else
								begin
									rx_State <= rx_State;
								end
						
						START:
							if(sample_Cnt == 3'd7)
								begin
									rx_State <= RECEIVE;
									sample_Cnt <= 4'd0;
								end
							else if(rx == 1'b1)
								begin
									rx_State <= IDLE;
									sample_Cnt <= 1'b0;
								end
							else
								begin
									rx_State <= START;
									sample_Cnt <= sample_Cnt + 1'b1;
								end
						
						RECEIVE:
							if(sample_Cnt == 4'd15)
								begin
									rx_Shift <= {rx, rx_Shift[7 : 1]};
									if(data_Cnt == 3'd7)
										begin
											rx_State <= STOP;
											data_Cnt <= 1'b0;
											sample_Cnt <= 1'b0;
										end
									else 
										begin
											data_Cnt <= data_Cnt + 1'b1;
											sample_Cnt <= 1'b0;
										end
								end
							else
								begin
									sample_Cnt <= sample_Cnt + 1'b1;
									rx_State <= RECEIVE;
								end
						
						STOP:
							if(sample_Cnt == 4'd15)
								begin
									rx_State <= IDLE;
									sample_Cnt <= 1'b0;
								end
							else
								begin
									sample_Cnt <= sample_Cnt + 1'b1;
									rx_State <= STOP;
								end
					endcase
				end
			
							
		assign		rx_Done = (rx_State == STOP) ? 1'b1 : 1'b0;
		assign		rx_Data = (rx_State == STOP) ? rx_Shift : 1'b0;
	
	endmodule