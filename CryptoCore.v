//SpoC-64 
// William Diehl
// Virginia Tech
// 05-31-2019

module CryptoCore(
        //! Global
        clk,
        rst,
        //! PreProcessor (data)
        key,
        bdi,
        //! PreProcessor (controls)
        key_ready,
        key_valid,
        key_update,
        hash_in,
        decrypt,
        bdi_ready,
        bdi_valid,
        bdi_type, 
        bdi_eot,    
        bdi_eoi,    
        bdi_size,   
        bdi_valid_bytes,
        bdi_pad_loc,
        //! PostProcessor
        bdo,
        bdo_valid,
        bdo_ready,
        bdo_type,
        bdo_valid_bytes,
		end_of_block,
        msg_auth,
		msg_auth_ready,
        msg_auth_valid
    );
	
input clk, rst, key_valid, key_update, hash_in, decrypt, bdi_valid, bdi_eot, bdi_eoi, bdo_ready, msg_auth_ready;
input [2:0] bdi_size;
input [3:0] bdi_type, bdi_valid_bytes, bdi_pad_loc;
input [31:0] key, bdi;

output key_ready, bdi_ready, bdo_valid, end_of_block, msg_auth, msg_auth_valid;
output [3:0] bdo_valid_bytes, bdo_type;
output [31:0] bdo;

wire en_key, en_npub, en_bdi, clr_bdi, en_cum_size, sel_tag;
wire start, done, init_state, bdo_complete, bdi_complete, en_state, lock_tag_state, bdi_partial_reg, msg_auth;
wire en_trunc, trunc_complete, init_trunc, decrypt_reg, init_lock;
wire [1:0] ctrl_word;

Datapath data_path_inst(
        .clk(clk),
        .rst(rst),

        //! Input Processor
        .key(key),
        .bdi(bdi),

        //! Output Processor
        .bdo(bdo),

        //! Controller
        .en_key(en_key),
        .en_npub(en_npub),
        .en_bdi(en_bdi),
		.clr_bdi(clr_bdi),
		.en_cum_size(en_cum_size),
		.en_trunc(en_trunc),
		.init_trunc(init_trunc),
		.trunc_complete(trunc_complete),
		.decrypt_reg(decrypt_reg),
        .sel_tag(sel_tag),		
        .start(start),
		.done(done),
		.init_state(init_state),
		.bdi_partial_reg(bdi_partial_reg),
		.msg_auth(msg_auth),
		.bdi_type(bdi_type),
		.bdi_size(bdi_size),
		.bdi_complete(bdi_complete),
		.bdo_complete(bdo_complete),
		.en_state_in(en_state),
		.init_lock(init_lock),
		.lock_tag_state(lock_tag_state),
		.ctrl_word(ctrl_word)
    );

Controller ctrl_inst(
        .clk(clk),
        .rst(rst),

        //! Input
        .key_ready(key_ready),
        .key_valid(key_valid),
        .key_update(key_update),
        .decrypt(decrypt),
        .bdi_ready(bdi_ready),
        .bdi_valid(bdi_valid),
		.bdi_type(bdi_type),
        .bdi_eot(bdi_eot),
        .bdi_eoi(bdi_eoi),
		.trunc_complete(trunc_complete),

		//! Output
        .msg_auth_valid(msg_auth_valid),
		.msg_auth_ready(msg_auth_ready),
		.bdo_valid_bytes(bdo_valid_bytes),
		.end_of_block(end_of_block),
        .bdo_ready(bdo_ready),
        .bdo_valid(bdo_valid),
		.bdi_size(bdi_size),
		.bdi_partial_reg(bdi_partial_reg),
        .en_key(en_key),
        .en_npub(en_npub),
        .en_bdi(en_bdi),
		.clr_bdi(clr_bdi),
		.en_cum_size(en_cum_size),
        .en_trunc(en_trunc),
        .start(start),
		.init_trunc(init_trunc),
		.decrypt_reg(decrypt_reg),
		.perm_done(done),
		.init_state(init_state),
		.init_lock(init_lock),
		.en_state(en_state),
		.lock_tag_state(lock_tag_state),
		.sel_tag(sel_tag),
		.bdi_complete(bdi_complete),
		.bdo_complete(bdo_complete),
		.ctrl_word(ctrl_word)
    );

endmodule 