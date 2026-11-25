module receiver (input clk, rx, clk_enb, rdy_clr, rst, output reg [7:0]data_out, output reg rdy);
parameter start_state = 2'b00;
parameter data_out_state = 2'b01;
parameter stop_state = 2'b10;

reg [1:0] state;
reg [3:0] sample;
reg [3:0] index;
reg [7:0] temp_register;

always@(posedge clk)
begin
if (rst)
begin
state <= start_state;
sample <= 4'd0;
index <= 3'd0;
temp_register <= 8'd0;
rdy <=0;
data_out <= 0;
end
else
begin
if(rdy_clr)
rdy <=1'b0;
if(clk_enb)
begin
case(state)

start_state:
begin
if(rx==1'b0)
begin
if(sample == 15)
begin
state <= data_out_state;
sample <= 4'd0;
index <= 3'd0;
temp_register <= 8'd0;
end
else
sample <= sample +1'b1;
end
else
begin
sample<=4'd0;
end
end


data_out_state:
begin
if(sample == 4'b1000)
temp_register [index] <= rx;

if(sample == 4'd15)
begin
sample <= 4'd0;

if (index == 7)
state<=stop_state;
else
index <= index+1'b1;
end
else 
begin
sample <= sample +1'b1;
end
end


stop_state: 
begin
if(sample ==15)
begin
sample<=0;

if(rx == 1'b1)
begin
data_out <= temp_register;
rdy <= 1'b1;
end
state <= start_state;
end
else 
begin
sample = sample +1'b1;
end
end

default: begin
state <= start_state;
sample <= 4'd0;
index <= 3'd0;
end

endcase
end
end
end
endmodule 
