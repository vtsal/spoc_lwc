//SpoC-64 
// William Diehl
// Virginia Tech
// 05-31-2019

module SLiSCP_step(
clk,
rst,
en_rnd_ctr,
sin,
rc1,
rc0,
sc1,
sc0,
rnd_done,
sout
);

parameter WIDTH = 48;

// global inputs
input clk, rst, en_rnd_ctr;
input [7:0] rc1, rc0, sc1, sc0;
input [WIDTH*4-1:0] sin;

output rnd_done;
output [WIDTH*4-1:0] sout;

wire [WIDTH-1:0] s0_in, s1_in, s2_in, s3_in;
wire [WIDTH-1:0] s1_after_ssb, s3_after_ssb, s0_after_asc, s2_after_asc;
wire [WIDTH-1:0] s0_out, s1_out, s2_out, s3_out;
wire [WIDTH-1:0] sc0_step, sc1_step;

assign sc0_step = {{(WIDTH-8){1'b1}},2'b00,sc0[5:0]};
assign sc1_step = {{(WIDTH-8){1'b1}},2'b00,sc1[5:0]};
assign s0_in = sin[WIDTH*4-1:WIDTH*3];
assign s1_in = sin[WIDTH*3-1:WIDTH*2];
assign s2_in = sin[WIDTH*2-1:WIDTH*1];
assign s3_in = sin[WIDTH*1-1:WIDTH*0];

SB #(WIDTH) S1(
.clk(clk),
.rst(rst),
.en_rnd_ctr(en_rnd_ctr),
.sin(s1_in),
.rc(rc0),
.rnd_done(rnd_done),
.sout(s1_after_ssb)
);

SB #(WIDTH) S3(
.clk(clk),
.rst(rst),
.en_rnd_ctr(en_rnd_ctr),
.sin(s3_in),
.rc(rc1),
// rnd_done is open
.sout(s3_after_ssb)
);

assign s0_after_asc = s0_in ^ sc0_step;
assign s2_after_asc = s2_in ^ sc1_step;
assign s3_out = s0_after_asc ^ s1_after_ssb;
assign s2_out = s3_after_ssb;
assign s1_out = s3_after_ssb ^ s2_after_asc;
assign s0_out = s1_after_ssb;
assign sout = {s0_out, s1_out, s2_out, s3_out};

endmodule