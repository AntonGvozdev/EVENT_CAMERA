`timescale 1ns / 1ps


module TX_GENERATOR(
input wire manual_tx,
input wire tx_done,
input wire clk,
output wire new_tx,
output wire res
    );
reg r = 0;    
reg r1 = 0;
reg r2= 0;
reg r22 = 0;
reg r3 = 0;
reg r30 = 0;
reg r33 = 0;
reg r333 = 0;
reg r4= 0;
reg r44= 0;
wire temp_tx1, temp_tx2;
assign temp_tx1 = r2 && !r22;
assign temp_tx2 = r4 && !r44;
assign new_tx = temp_tx1 || temp_tx2;//
assign res = r;
always @(posedge clk) begin
    r1 <= manual_tx;
    r2 <= r1;
    r22 <=r2;
    r3 <= tx_done;
    r30 <= r3;
    r33 <= r30;
    r333 <= r33;
    r4 <= r333;
    r44 <= r4;
end

endmodule
