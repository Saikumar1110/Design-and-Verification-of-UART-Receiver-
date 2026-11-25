`timescale 1ns/1ps


module uart_receiver #(parameter [7:0] clks_per_bit = 8'd217) (input wire clk, input wire rst_n, input wire serial_in, output reg [7:0]data_out, output reg data_ready); //clks_per_bit is declared using paramter as we can change the value during instantiation


localparam idle = 2'b00;
localparam start = 2'b01;
localparam recv = 2'b10;
localparam stop = 2'b11;

reg [1:0] state;
reg [7:0] clk_count; // used to count 217 clock pulses 
reg [2:0] bit_index;
reg [7:0] data_buf;

//two stage Synchronizer 
reg rx_meta;
reg rx_sync;

always @(posedge clk)
begin
	rx_meta <= serial_in;
	rx_sync <= rx_meta;
end

// UART Receiver FSM
always @(posedge clk)
begin
	if(!rst_n)
	begin
		state <= idle;
		clk_count <= 8'd0;
		bit_index <= 3'd0;
		data_buf <= 8'd0;
		data_out <= 8'd0;
		data_ready <= 1'b0;
	end

	else begin
		data_ready <= 1'b0;
		case (state)
			idle: 
			begin
				clk_count <= 8'd0;
				bit_index <= 3'd0;
				if (rx_sync == 1'b0)
					state <= start; //since start bit rx_sync = 1'b0 has arrived, we go to the start state.
			end



			start: 
			begin
				if (clk_count == (clks_per_bit >> 1))
				begin	// eaxactly at 217/2 clock cycle we are checking 
					clk_count <= 8'd0;
				if(rx_sync == 1'b0) // whether rx_sync is still 0 or not ( as 0 indicates the start bit)
					state <= recv ; // since it is zero, that indicates the start bit, the go to next state receive state. 
				else
					state <= idle;
			end	// if not, its a false signal, sta in the same state
				else 
				begin
					clk_count <= clk_count +1'b1; // if clk_count is not equalto 217/2, then increment the clk_count
				end
			end

			recv: 
			begin
				if(clk_count == clks_per_bit-1)
				begin
					clk_count <= 8'd0;
					data_buf[bit_index] <= rx_sync;
					if(bit_index == 3'd7)
					begin
						bit_index <= 3'd0;
						state <= stop;
					end
					else 
					begin
						bit_index <= bit_index + 1'b1;
					end
				end
				else begin
					clk_count <= clk_count + 1'b1;
				end
			end

			stop: begin
				if(clk_count == clks_per_bit - 1)
				begin
					clk_count <= 8'd0;
					data_out <= data_buf;
					data_ready <= 1'b1;
					state <= idle;
				end
				else
				begin
					clk_count <= clk_count +1'b1;
				end
			end


			default: begin
				state <= idle;
			end

		endcase
	end
end
endmodule
