
module pass_next(
input wire [31:0]data_in,
input wire [31:0]data_in_time,
input wire [31:0]data_in_tx,
output reg [31:0]data_out,
input wire r_next,
input wire new_tx,

input wire res
 );


reg switch = 0;
reg [31:0]counter = 0;
reg flag = 0;
reg r1, r2;

always @(posedge r_next) begin
    r1 <= new_tx;
    r2 <= r1;
end

always @(posedge r_next) 
begin       
            if (switch==0) begin
                    if (flag) begin
                        data_out <= data_in_tx;
                    end else begin
                        data_out <=data_in;
                    end
            end 
            else begin
                   if (flag) begin
                        data_out <= data_in_tx;
                   end else begin
                        data_out <=data_in_time;
                   end
            end
end

always @(negedge r_next or posedge new_tx)
begin
        switch <= ~switch;
        if (new_tx) begin
        counter <=0;
        flag <= 0;
        end else begin
        if (counter == 10'h3FD) ////WAS WORKING WITH 3FC
            begin
            counter <=0;
            flag <= 1;
            end
        else begin 
            counter <= counter + 1'h1; 
            flag <= 0;
            end
         end
end

endmodule
