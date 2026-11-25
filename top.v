module uart_top (input rst, clk, wr_enb, rdy_clr, input [7:0] data_in, output rdy, busy, output [7:0] data_out); 

wire rx_clk_enb; //for collecting output of baud rate generator rx_enb signal
wire tx_clk_enb; // for Collecting output of Baud rate generator tx_enb signal

wire tx_temp;

baud_rate_gen br (.clk(clk), .reset(rst), .tx_enb(tx_clk_enb), .rx_enb(rx_clk_enb));
transmitter tr(.clk(clk), .wr_enb(wr_enb), .enb(tx_clk_enb), .rst(rst), .data_in(data_in),.tx(tx_temp),.busy(busy));
receiver rr(.clk(clk), .rx(tx_temp), .clk_enb(rx_clk_enb), .rdy_clr(rdy_clr), .rst(rst),.data_out(data_out),.rdy(rdy));
endmodule 


