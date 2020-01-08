//SpoC-64 
// William Diehl
// Virginia Tech
// 05-31-2019

module SB(
clk,
rst,
en_rnd_ctr,
sin,
rc,
rnd_done,
sout
);

parameter WIDTH = 48;
localparam MAXCTR = 3'b101;

// global inputs
input clk, rst, en_rnd_ctr;
input [7:0] rc;
input [WIDTH-1:0] sin;

output rnd_done;
output [WIDTH-1:0] sout;

wire [WIDTH-1:0] sin, sout, next_status, status;
wire [7:0] rc, rc_rnd, rc_reg, next_rc_reg;
wire en_rnd_ctr;
wire [WIDTH/2-1:0] upper_half, lower_half, lower_half_input;
wire [2:0] next_rnd_ctr, rnd_ctr;

assign rnd_done = (rnd_ctr == MAXCTR) ? 1 : 0;
assign next_rnd_ctr = (rnd_ctr == MAXCTR) ? 0 : rnd_ctr + 1;

d_ff #(3) rnd_ctr_reg(
.clk(clk),
.rst(rst),
.en(en_rnd_ctr),
.d(next_rnd_ctr),
.q(rnd_ctr)
);

assign lower_half_input = (rnd_ctr ==0) ? sin[WIDTH/2-1:0] : status[WIDTH/2-1:0];
assign upper_half = (rnd_ctr == 0) ? sin[WIDTH-1:WIDTH/2] : status[WIDTH-1:WIDTH/2];
assign rc_rnd = (rnd_ctr == 0) ? rc : rc_reg;
assign lower_half = {upper_half[WIDTH/2-1-5:0],upper_half[WIDTH/2-1:WIDTH/2-1-4]} & upper_half ^
                    {upper_half[WIDTH/2-1-1:0],upper_half[WIDTH/2-1]} ^ lower_half_input ^ {{(WIDTH/2-1){1'b1}},rc_rnd[0]}; 
assign next_status = {lower_half, upper_half};
assign sout = next_status;

d_ff #(WIDTH) status_reg(
.clk(clk),
.rst(rst),
.en(en_rnd_ctr),
.d(next_status),
.q(status)
);

assign next_rc_reg = {1'b0, rc_rnd[6:1]};

d_ff #(8) rc_rg(
.clk(clk),
.rst(rst),
.en(en_rnd_ctr),
.d(next_rc_reg),
.q(rc_reg)
);
endmodule