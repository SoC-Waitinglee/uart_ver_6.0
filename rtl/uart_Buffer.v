`include "./uart_Define.v"

	module		uart_Buffer(
		sample_Clk,
		reset,
		button_Trig,
		
		wr_Sig,
		test_Data,
		
		tx_Start,
		tx_Data,
		
		sig_Full,
		sig_Empty);
		
		
		input		sample_Clk;
		input		reset;
		input		button_Trig;
		
		input		wr_Sig;
		input		[7 : 0]		test_Data;
		
		output		tx_Start;
		output		[7 : 0]		tx_Data;
		
		output         sig_Full;
		output         sig_Empty;
		
		
		parameter	BUFFER_DEPTH = 8;
		parameter	BUFFER_WIDTH = 8;
		parameter	POINTER_SIZE = 3;
		parameter	fifo_Enable = 1;
		
		//Load Buttton Debounce Parameter //
		//parameter		DEBOUNCE_TIME = 15'b100101100000000; // 307200bps
		parameter		DEBOUNCE_TIME = 15'd100;
		// Load Button Debounce Register & Wire //
		reg		[14:0]	deb_Count;
		wire			tx_Start;
		// Button Debounce Trigger//			
		always@(posedge sample_Clk or negedge reset)			// ?•œ ì£¼ê¸°ë§? HIGH?‹œ?‚¤ê¸? ?œ„?•œ Logic //
			begin
				if(~reset)
					deb_Count <= 1'b0;
				else if(~button_Trig)
					if(deb_Count == DEBOUNCE_TIME)
						deb_Count <= DEBOUNCE_TIME;
					else
						deb_Count <= deb_Count + 1'b1;
				else
					deb_Count <= 1'b0;
			end
			
		assign tx_Start = (deb_Count == DEBOUNCE_TIME-1'b1) ? 1'b1 : 1'b0;
		
		reg		[BUFFER_WIDTH-1:0] fifo_Memory[BUFFER_DEPTH-1:0];
		reg		[POINTER_SIZE-1:0] wr_Ptr;
		reg		[POINTER_SIZE-1:0] rd_Ptr;
		reg						full_Reg;
		reg						empty_Reg;
		// FIFO Sequential Logic //
		always@(posedge sample_Clk or negedge reset)
			begin
				if(~reset)
					begin
						fifo_Memory[0] <= 8'h11;
						fifo_Memory[1] <= 8'h22;
						fifo_Memory[2] <= 8'h33;
						fifo_Memory[3] <= 8'h44;
						fifo_Memory[4] <= 8'h55;
						fifo_Memory[5] <= 8'h66;
						fifo_Memory[6] <= 8'h77;
						fifo_Memory[7] <= 8'h88;
						rd_Ptr <= 2'b10;
						wr_Ptr <= 1'b0;
						full_Reg <= 1'b0;
						empty_Reg <= 1'b1;
					end
				else
					begin
						if((full_Reg == 1'b0) && (wr_Sig == 1'b1))
							begin
								fifo_Memory[wr_Ptr] <= test_Data;
								empty_Reg <= 1'b0;
								wr_Ptr <= wr_Ptr + 1'b1;
								if((wr_Ptr + 1'b1) == rd_Ptr)
									full_Reg <= 1'b1;
							end
						else if((empty_Reg == 1'b0) && (tx_Start == 1'b1))
							begin
								full_Reg <= 1'b0;
								rd_Ptr <= rd_Ptr + 1'b1;
								if((rd_Ptr + 1'b1) == wr_Ptr)
									empty_Reg <= 1'b1;							
							end
					end
			end
			
			

								
		assign	sig_Full 	= full_Reg;
		assign	sig_Empty 	= empty_Reg;
		assign	tx_Data 	= tx_Start ? fifo_Memory[rd_Ptr] : 1'b1;
	endmodule	
			