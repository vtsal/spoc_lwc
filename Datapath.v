//SpoC-64 
// William Diehl
// Virginia Tech
// 05-31-2019

module Datapath(
clk,
rst,
start,
done,
bdi,
key,
bdo,
init_state,
en_key,
en_npub,
en_bdi,
clr_bdi,
en_cum_size,
en_trunc,
init_trunc,
bdi_partial_reg,
msg_auth,
bdi_type,
bdi_size,
decrypt_reg,

trunc_complete,
bdi_complete,
bdo_complete,
en_state_in,
sel_tag,
init_lock,
lock_tag_state,
ctrl_word

);

parameter WIDTH = 48,
		  PW = 32,
		  SW = 32,
          G_KEY_SIZE = 128,
		  G_NPUB_SIZE = 128;

localparam MAXCTR = 17,
           AD_TYPE = 4'b0001;

input clk, rst;
input start, init_state, bdo_complete, en_state_in, sel_tag, init_lock, lock_tag_state;
input en_trunc, init_trunc;
input en_key, en_npub, en_bdi, clr_bdi, en_cum_size, bdi_partial_reg, bdi_complete, decrypt_reg;
input [1:0] ctrl_word;
input [2:0] bdi_type;
input [2:0] bdi_size;
input [PW-1:0] bdi;
input [SW-1:0] key;

output msg_auth;
output done, trunc_complete;
output [PW-1:0] bdo;

wire rnd_done, step_done;
wire en_state;
wire [1:0] state_sel, bdo_sel;
wire [2:0] bdi_size;
wire [3:0] ctrl_code;
wire [3:0] cum_size, next_cum_size;
wire [4:0] step_ctr, next_step_ctr;
wire [31:0] tag_high, tag_low, ptct_high, ptct_low;
wire [63:0] z_ip1;
wire [63:0] bdi_reg, next_bdi_reg, bdi_pad_half, bdi_pad_input;
wire [63:0] proc_input;
wire [63:0] state_trunc;
wire [127:0] y_ip1;
wire [WIDTH*4-1:0] next_state, state, step_in, step_out;
wire [WIDTH*4-1:0] load_spoc_64, init_state_load, proc_state, proc_chain, bdi_pad;

reg en_rnd_ctr, en_step_ctr, done;
reg next_fsm_state, fsm_state;
reg [3:0] trunc_count;
reg [7:0] rc0, rc1, sc0, sc1;
reg [63:0] trunc_mask;
reg [G_KEY_SIZE-1:0] key_reg;
reg [G_NPUB_SIZE-1:0] npub_reg;

// load key & npub
// requires 16 byte load of key and npub (shorter lengths not permitted)

always @(posedge clk)
	begin	
		if (en_key == 1) 	
			key_reg <= {key_reg[G_KEY_SIZE - SW - 1:0],key}; // left shift load
		
		if (en_npub == 1)	
			npub_reg <= {npub_reg[G_NPUB_SIZE - PW - 1:0],bdi}; // left shift load
	end

// initialization

assign load_spoc_64 = {npub_reg[127:96],key_reg[79:64],key_reg[127:80],npub_reg[95:64],key_reg[15:0],key_reg[63:16]};
assign init_state_load = {step_out[191:144], (npub_reg[63:32] ^ step_out[143:112]), step_out[111:48], (npub_reg[31:0] ^ step_out[47:16]), step_out[15:0]};

// step function

assign step_in = (init_state == 1) ? load_spoc_64 : state;

SLiSCP_step #(WIDTH) step_func(
.clk(clk),
.rst(rst),
.en_rnd_ctr(en_rnd_ctr), 
.sin(step_in),
.rc1(rc1),
.rc0(rc0),
.sc1(sc1),
.sc0(sc0),
.rnd_done(rnd_done),
.sout(step_out)
);

assign step_done = (step_ctr == MAXCTR) ? 1 : 0;
assign next_step_ctr = (step_ctr == MAXCTR) ? 0 : step_ctr + 1;

d_ff #(5) step_ctr_reg(
.clk(clk),
.rst(rst),
.en(en_step_ctr),
.d(next_step_ctr),
.q(step_ctr)
);

// rc0 LUT

always @(step_ctr)
case(step_ctr)
    5'b00000 : rc0 = 8'h07;
    5'b00001 : rc0 = 8'h04;
    5'b00010 : rc0 = 8'h06;
    5'b00011 : rc0 = 8'h25;
	5'b00100 : rc0 = 8'h17;
	5'b00101 : rc0 = 8'h1C;
	5'b00110 : rc0 = 8'h12;
    5'b00111 : rc0 = 8'h3B;
    5'b01000 : rc0 = 8'h26;
    5'b01001 : rc0 = 8'h15;
    5'b01010 : rc0 = 8'h3F;
    5'b01011 : rc0 = 8'h20;
    5'b01100 : rc0 = 8'h30;
    5'b01101 : rc0 = 8'h28;
    5'b01110 : rc0 = 8'h3C;
    5'b01111 : rc0 = 8'h22;
    5'b10000 : rc0 = 8'h13;
    5'b10001 : rc0 = 8'h1A;
    default  : rc0 = 8'h00;
endcase

// rc1 LUT

always @(step_ctr)
case(step_ctr)
    5'b00000 : rc1 = 8'h27;
    5'b00001 : rc1 = 8'h34;
    5'b00010 : rc1 = 8'h2E;
    5'b00011 : rc1 = 8'h19;
	5'b00100 : rc1 = 8'h35;
	5'b00101 : rc1 = 8'h0F;
	5'b00110 : rc1 = 8'h08;
    5'b00111 : rc1 = 8'h0C;
    5'b01000 : rc1 = 8'h0A;
    5'b01001 : rc1 = 8'h2F;
    5'b01010 : rc1 = 8'h38;
    5'b01011 : rc1 = 8'h24;
    5'b01100 : rc1 = 8'h36;
    5'b01101 : rc1 = 8'h0D;
    5'b01110 : rc1 = 8'h2B;
    5'b01111 : rc1 = 8'h3E;
    5'b10000 : rc1 = 8'h01;
    5'b10001 : rc1 = 8'h21;
    default  : rc1 = 8'h00;
endcase

// sc0 LUT

always @(step_ctr)
case(step_ctr)
    5'b00000 : sc0 = 8'h08;
    5'b00001 : sc0 = 8'h0C;
    5'b00010 : sc0 = 8'h0A;
    5'b00011 : sc0 = 8'h2F;
	5'b00100 : sc0 = 8'h38;
	5'b00101 : sc0 = 8'h24;
	5'b00110 : sc0 = 8'h36;
    5'b00111 : sc0 = 8'h0D;
    5'b01000 : sc0 = 8'h2B;
    5'b01001 : sc0 = 8'h3E;
    5'b01010 : sc0 = 8'h01;
    5'b01011 : sc0 = 8'h21;
    5'b01100 : sc0 = 8'h11;
    5'b01101 : sc0 = 8'h39;
    5'b01110 : sc0 = 8'h05;
    5'b01111 : sc0 = 8'h27;
    5'b10000 : sc0 = 8'h34;
    5'b10001 : sc0 = 8'h2E;
    default  : sc0 = 8'h00;
endcase

// sc1 LUT

always @(step_ctr)
case(step_ctr)
    5'b00000 : sc1 = 8'h29;
    5'b00001 : sc1 = 8'h1D;
    5'b00010 : sc1 = 8'h33;
    5'b00011 : sc1 = 8'h2A;
	5'b00100 : sc1 = 8'h1F;
	5'b00101 : sc1 = 8'h10;
	5'b00110 : sc1 = 8'h18;
    5'b00111 : sc1 = 8'h14;
    5'b01000 : sc1 = 8'h1E;
    5'b01001 : sc1 = 8'h31;
    5'b01010 : sc1 = 8'h09;
    5'b01011 : sc1 = 8'h2D;
    5'b01100 : sc1 = 8'h1B;
    5'b01101 : sc1 = 8'h16;
    5'b01110 : sc1 = 8'h3D;
    5'b01111 : sc1 = 8'h03;
    5'b10000 : sc1 = 8'h02;
    5'b10001 : sc1 = 8'h23;
    default  : sc1 = 8'h00;
endcase

// SLiSCP controller

//Synchronous Process
localparam INIT_ST = 1'b0,
           RUN_ST = 1'b1;		   

always @(posedge clk)
begin
	if (rst == 1'b1) fsm_state <= INIT_ST; 
	else fsm_state <= next_fsm_state;
end

// State Process
always @(fsm_state or start or rnd_done or step_done)
begin

// defaults to eliminate latches

en_rnd_ctr <= 0; // result assumed to not be ready
next_fsm_state <= INIT_ST;
en_step_ctr <= 0;
done <= 0;

      case (fsm_state)

	  INIT_ST: 
      begin
	    
		if (start == 1) begin
			en_rnd_ctr <= 1;
			next_fsm_state <= RUN_ST;
		end else begin
			done <= 1;
			next_fsm_state <= INIT_ST;
			end
		end
 
       RUN_ST:
	   begin
	   en_rnd_ctr <= 1;
	   if (rnd_done == 1)begin
            en_step_ctr <= 1;	   
			if (step_done == 1) begin
				done <= 1;
				next_fsm_state <= INIT_ST;
			end else
				next_fsm_state <= RUN_ST;
			end
		else
			next_fsm_state <= RUN_ST;
		end
		
		default: begin 
						next_fsm_state <= INIT_ST; // should never get here
				  end
		endcase
end
// opt.oz.pad

// choose encrypt or decrypt
assign bdi_pad_input = (ctrl_word[1] == 0 || decrypt_reg == 0) ? bdi_reg : {ptct_high, ptct_low};

// compute padding

assign bdi_pad_half = (cum_size == 4'b0001) ? {bdi_pad_input[63:56], 8'b1000_0000, {{48}{1'b0}}} : 64'bz;
assign bdi_pad_half = (cum_size == 4'b0010) ? {bdi_pad_input[63:48], 8'b1000_0000, {{40}{1'b0}}} : 64'bz;
assign bdi_pad_half = (cum_size == 4'b0011) ? {bdi_pad_input[63:40], 8'b1000_0000, {{32}{1'b0}}} : 64'bz;
assign bdi_pad_half = (cum_size == 4'b0100) ? {bdi_pad_input[63:32], 8'b1000_0000, {{24}{1'b0}}} : 64'bz;
assign bdi_pad_half = (cum_size == 4'b0101) ? {bdi_pad_input[63:24], 8'b1000_0000, {{16}{1'b0}}} : 64'bz;
assign bdi_pad_half = (cum_size == 4'b0110) ? {bdi_pad_input[63:16], 8'b1000_0000, {{8}{1'b0}}} : 64'bz;
assign bdi_pad_half = (cum_size == 4'b0111) ? {bdi_pad_input[63:8], 8'b1000_0000} : 64'bz;
assign bdi_pad_half = (cum_size == 4'b1000) ? bdi_pad_input : 64'bz;
assign bdi_pad_half = (cum_size == 4'b0000) ? 0 : 64'bz;

assign next_bdi_reg = (clr_bdi == 1) ? 0 :
                      (bdi_complete == 0) ? {bdi, {{32}{1'b0}}} : {bdi_reg[63:32], bdi};

d_ff #(64) bdi_rg(
.clk(clk),
.rst(rst),
.en(en_bdi),
.d(next_bdi_reg),
.q(bdi_reg)
);

assign next_cum_size = (clr_bdi == 1) ? 0 : cum_size + {1'b0, bdi_size};

d_ff #(4) cum_size_rg(
.clk(clk),
.rst(rst),
.en(en_cum_size),
.d(next_cum_size),
.q(cum_size)
);

// proc

assign proc_input = bdi_pad_half;
assign proc_chain = {state[191:188] ^ ctrl_code, state[187:144], (proc_input[63:32] ^ state[143:112]), state[111:64]};
assign y_ip1 = (lock_tag_state == 0) ? proc_chain : {(state[191]^1'b1),state[190:64]};
assign ctrl_code = {1'b0, ctrl_word, bdi_partial_reg};
assign z_ip1 = (lock_tag_state == 0) ? {state[63:48], state[47:16] ^ proc_input[31:0], state[15:0]} : state[63:0];
assign proc_state = {y_ip1,z_ip1};

// state 

assign next_state = (init_lock == 1) ? init_state_load :
                    (rnd_done == 1) ? step_out : 
					(init_state == 0) ? proc_state : load_spoc_64;
					
assign en_state = rnd_done | en_state_in;

d_ff #(WIDTH*4) state_reg(
.clk(clk),
.rst(rst),
.en(en_state),
.d(next_state),
.q(state)
);

// output chain

// serial truncator

always @(posedge clk)
begin
	if (rst == 1'b1 || init_trunc == 1) begin
		trunc_mask <= 64'hFFFF_FFFF_FFFF_FFFF;
		trunc_count <= 4'b1000;

	end else if (en_trunc == 1) begin
		trunc_mask <= {trunc_mask[55:0], 8'h00};
		trunc_count <= trunc_count - 1;
	end
end

assign trunc_complete = (trunc_count == cum_size) ? 1 : 0;

assign ptct_high = bdi_reg[63:32] ^ (trunc_mask[63:32] & state[191:160]); 
assign ptct_low = bdi_reg[31:0] ^ (trunc_mask[31:0] & state[95:64]); 
assign tag_high = state[143:112];
assign tag_low = state[48:16];

assign bdo_sel = {sel_tag, bdo_complete};

assign bdo = (bdo_sel == 2'b00) ? ptct_high : 32'bz;
assign bdo = (bdo_sel == 2'b01) ? ptct_low : 32'bz;
assign bdo = (bdo_sel == 2'b10) ? tag_high : 32'bz;
assign bdo = (bdo_sel == 2'b11) ? tag_low : 32'bz;

assign msg_auth = (bdi_reg[63:32] == tag_high && bdi_reg[31:0] == tag_low) ? 1 : 0;

endmodule