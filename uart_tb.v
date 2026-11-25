module uart_tb ();

reg rst, clk;
reg wr_enb; 
reg rdy_clr;
reg [7:0] data_in; 
wire rdy, busy; 
wire [7:0] data_out; 

uart_top uart (rst, clk, wr_enb, rdy_clr, data_in, rdy, busy, data_out); 

always #5 clk = ~clk;

initial
begin
clk = 0;
rst = 1;
wr_enb = 0;
rdy_clr = 0;
data_in = 8'h00;
#30;
rst=0;
end



task send_byte (input [7:0] din); // task used to send the data

begin
@(negedge clk);
data_in = din;
wr_enb = 1'b1;
@(negedge clk);
wr_enb = 1'b0;
end
endtask


task clear_ready;
begin
@(negedge clk);
rdy_clr = 1'b1;
@(negedge clk);
rdy_clr = 1'b0;
end
endtask

initial
begin
wait(!rst);
send_byte(8'h41);
wait(busy);
wait(!busy); // wait till busy signal becomes 0
wait(rdy); // wait till rdy signal becomes 1

$display ("The received data is %h", data_out);
clear_ready();
#1000 $finish;
end

endmodule
