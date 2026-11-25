module transmitter (input clk, wr_enb, enb, rst, input [7:0] data_in, output reg tx, output busy);

parameter idle_state = 2'b00;
parameter start_state = 2'b01;
parameter data_state = 2'b10;
parameter stop_state = 2'b11;

reg [7:0] data ;
reg [2:0] index;
reg [1:0] state;

always@(posedge clk)
begin
if(rst)
begin
state <= idle_state;
tx <= 1'b1;
index <= 3'd0;
data <= 8'd0;
end

else
begin

case(state)
//IDLE state
idle_state:
begin
tx<=1'b1;
if(wr_enb)
begin
state <= start_state;
data <= data_in;
index <= 3'b000;
end
else
state <= idle_state;
end


start_state:
begin
if(enb)
begin
tx <=1'b0;
state <= data_state;
end
else
state <= start_state;
end

data_state:
begin
	if (enb)
	begin
		tx <= data[index];
		if(index == 3'b111)
		begin
			state <= stop_state;
		end
		else 
		begin
			index <= index +1'b1;

		end
	end
end


stop_state:
begin
	if(enb)
	begin
		tx <= 1'b1;
		state <= idle_state;
	end
end

default: 
begin
	tx <= 1'b1;
	state <= idle_state;
	index <= 1'b0;
end

endcase
end
end

assign busy = (state != idle_state);

endmodule











