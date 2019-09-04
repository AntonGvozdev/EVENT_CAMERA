
module davis_240(
input wire clk,
input wire[8:0]AER_bus,
input wire REQ,
input wire SEL,
output wire ACK,
output reg [31:0]data_out,
output reg [31:0]data_out_time     
    );
//***********START VAR DEFINITION***********

//Parameters for counters
parameter TIMESTAMP_RESOLUTION = 100;//32 for 0.5us || 64 for 1us at 100MHz || D7 for 1 us at 215 || FA @ 215
parameter  X_DELAY_TIME    = 40;//in clock counts
parameter  Y_DELAY_TIME    = 40;
parameter  X_EXTEND_TIME    = 10;
parameter  Y_EXTEND_TIME    = 10;
parameter  ACK_HOLD_TIME    = 10;


//Internal signals
wire [7:0]AER_Y;
wire [8:0]AER_X;

reg ack = 1;
reg [8:0]X_addr_p = 0;
reg [7:0]Y_addr = 0;

reg reset = 0;

reg [31:0] y_delay_counter = 0;
reg [31:0] x_delay_counter = 0;
reg [31:0] ack_hold_counter = 0;

reg [31:0] time_stamp = 0;
reg [31:0] time_register = 0;
//States
parameter WAIT_REQ = 0;
parameter DELAY_Y = 1;
parameter GET_Y = 2;
parameter SEND_ACK = 3;
parameter DELAY_X = 4;
parameter GET_X = 5;

//State outputs
reg [3:0] state = 0;

reg req_ready = 0;
reg sel = 0;
reg y_done = 0;
reg x_done = 0;
reg y_delay_done = 0;
reg x_delay_done = 0;
reg ack_done = 0;


// Input bus control
assign ACK = ack;

assign AER_Y[0] = AER_bus[0];
assign AER_Y[1] = AER_bus[1];
assign AER_Y[2] = AER_bus[2];
assign AER_Y[3] = AER_bus[3];
assign AER_Y[4] = AER_bus[4];
assign AER_Y[5] = AER_bus[5];
assign AER_Y[6] = AER_bus[6];
assign AER_Y[7] = AER_bus[7];

assign AER_X[0] = AER_bus[0];
assign AER_X[1] = AER_bus[1];
assign AER_X[2] = AER_bus[2];
assign AER_X[3] = AER_bus[3];
assign AER_X[4] = AER_bus[4];
assign AER_X[5] = AER_bus[5];
assign AER_X[6] = AER_bus[6];
assign AER_X[7] = AER_bus[7];
assign AER_X[8] = AER_bus[8];

//***********END VAR DEFINITION***********

//***********START LOGIC***********
//Sync SEL
reg temp_sel = 0;  always @(posedge clk) begin temp_sel <= SEL; end
reg SEL_synq = 0;  always @(posedge clk) begin SEL_synq <= temp_sel; end
//Sync REQ
reg temp = 0;  always @(posedge clk) begin temp <= REQ; end
reg REQ_synq = 0;  always @(posedge clk) begin REQ_synq <= temp; end
//Generate timestamp
reg [6:0]counter = 0;
always@(posedge clk)
begin
    if (counter == TIMESTAMP_RESOLUTION)
    begin
        counter <= 0;
        time_stamp <= time_stamp + 1;
    end
    else begin counter <= counter + 1; end
end
//STATE MACHINE FOR DAVIS
always @ (posedge clk)
begin
  case(state)
    WAIT_REQ : begin
                if (REQ == 0) begin //SYNC
                    //ack <= 1;
                    if (SEL == 0) begin //SYNC
                        state <= DELAY_Y;
                    end else begin
                        state <= DELAY_X;
                    end
                end else begin
                    y_done <= 0;
                    x_done <= 0;
                    ack <= 1;
                    state <= WAIT_REQ;
                end
               end
   GET_Y :  begin
                   Y_addr <= AER_Y;
                   state <= SEND_ACK;
            end
   DELAY_Y :  begin
                   if (y_delay_counter == Y_DELAY_TIME) begin
                    y_delay_counter <= 0;
                    state <= GET_Y;
                   end else begin
                    y_delay_counter <= y_delay_counter + 1;
                    state <= DELAY_Y;
                   end
            end
   GET_X : begin
                   X_addr_p <= AER_X;
                   time_register <= time_stamp;
                   x_done <= 1;
                   state <= SEND_ACK;
            end
   DELAY_X :  begin
                   if (x_delay_counter == X_DELAY_TIME) begin
                    x_delay_counter <= 0;
                    state <= GET_X;
                   end else begin
                    x_delay_counter <= x_delay_counter + 1;
                    state <= DELAY_X;
                   end
              end
   SEND_ACK : begin
                  if (ack_hold_counter == ACK_HOLD_TIME) begin
                    ack_hold_counter <= 0;
                    ack <= 0;
                    state <= WAIT_REQ;
                  end else begin
                    ack_hold_counter <= ack_hold_counter + 1;
                    ack <= 0;
                    state <= SEND_ACK;
                  end
                end
   default : begin
                  state <= WAIT_REQ;
             end
  endcase
end

always @(posedge x_done)
begin
    /*data_out[7:0] <= Y_addr;
    data_out[31:8] <= 0;
    data_out_time[7:0] <= X_addr_p;
    data_out_time[31:8] <= 0;*/
    data_out[7:0] <= Y_addr;
    data_out[16:8] <= X_addr_p;
    data_out[31:17] <= 0;
    data_out_time[31:0] <= time_register;

end

endmodule
