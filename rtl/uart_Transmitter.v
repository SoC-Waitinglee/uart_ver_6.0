`include "./uart_Define.v"

	module	uart_Transmitter(
		sample_Clk,
		reset,
		tx_Data,
		tx_Start,
		
		tx);
		
		
		input				sample_Clk;
		input				reset;
		input	[7 : 0]		tx_Data;
		input				tx_Start;
		
		output		tx;
		
		parameter	[1 : 0]		IDLE = 2'b00,
								START = 2'b01,
								TRANSMIT = 2'b10,
								STOP = 2'b11;
		
		
		
		reg						tx_Reg;
		reg			[1 : 0]		tx_State;	
		reg			[7 : 0]		tx_Buffer;	
		reg			[3 : 0]		data_Cnt;	
		always@(posedge sample_Clk or negedge reset)
			begin
				if(~reset)
					begin
						tx_State <= IDLE;
						tx_Buffer <= 1'b0;
						data_Cnt <= 1'b0;
					end
				else
					begin
						case(tx_State)
							IDLE:
								if(tx_Start)
									begin
										tx_Buffer <= tx_Data;
										tx_State <= START;
										tx_Reg <= 1'b0;
									end
								else
									begin
										tx_State <= tx_State;
										tx_Reg <= 1'b1;
									end
							
							START:
								begin
									tx_Reg <= tx_Buffer[0];
									tx_State <= TRANSMIT;
								end
							
							TRANSMIT:
								begin
									tx_Reg <= tx_Buffer[data_Cnt + 1];
									if(data_Cnt == 3'd7)
										begin
											data_Cnt <= 1'b0;
											tx_State <= STOP;
										end
									else
										begin
											data_Cnt <= data_Cnt + 1'b1;
											tx_State <= tx_State;
										end
								end
							
							STOP:
								begin
									tx_State <= IDLE;
									tx_Reg <= 1'b1;
								end
						endcase
					end
			end
			
	assign			tx = (tx_State == STOP) ? 1'b1 : tx_Reg;
	
	endmodule