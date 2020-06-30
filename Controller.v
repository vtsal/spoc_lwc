//SpoC-64 
// William Diehl
// Virginia Tech
// 05-31-2019

module Controller(

// input

// AEAD
clk,
rst,
bdi_valid,
bdo_ready,
key_update,
key_valid,
bdi_eoi,
bdi_eot,
bdi_type,
bdi_partial,
bdi_size,
decrypt,
msg_auth_ready,

// Datapath
perm_done,
trunc_complete,

//output

// AEAD
bdi_ready,
bdo_valid,
key_ready,
bdo_valid_bytes,
end_of_block,
msg_auth_valid,

// Datapath
sel_tag,
en_key,
en_npub,
en_bdi,
clr_bdi,
en_cum_size,
en_trunc,
init_trunc,
start,
decrypt_reg,
bdi_partial_reg,
init_state,
init_lock,
en_state,
lock_tag_state,
bdi_complete,
bdo_complete,
ctrl_word
);

input clk, rst, bdi_valid, key_update, key_valid, bdi_eoi, bdi_eot, bdi_partial, decrypt, msg_auth_ready, perm_done; 
input bdo_ready, trunc_complete;
input [2:0] bdi_size;
input [3:0] bdi_type;

output bdi_ready, bdo_valid, key_ready, msg_auth_valid, end_of_block, sel_tag, en_key, en_npub, en_bdi, clr_bdi, en_cum_size;
output init_state, init_lock, en_state, start, lock_tag_state, bdo_complete, bdi_complete, bdi_partial_reg, en_trunc, init_trunc;
output decrypt_reg;
output [1:0] ctrl_word;
output [3:0] bdo_valid_bytes;

reg key_ready, en_key, clr_ld_ctr, en_ld_ctr, en_npub, en_decrypt_reg;
reg bdi_ready, bdo_valid, msg_auth_valid, end_of_block, sel_tag, en_bdi, clr_bdi, en_cum_size, en_trunc, init_trunc;
reg start, init_state, init_lock, en_state, lock_tag_state, bdi_complete, bdo_complete;
reg set_eot_flag, reset_eot_flag, set_eoi_flag, reset_eoi_flag, eoi_flag, eot_flag, decrypt_reg;
reg set_bdi_complete, reset_bdi_complete, set_bdo_complete, reset_bdo_complete;
reg store_bdi_type, bdi_type_reg, bdi_partial_reg, store_bdi_partial;
reg [1:0] ctrl_word, ld_ctr;
reg [3:0] fsm_state, next_fsm_state, bdo_valid_bytes;

//Synchronous Process
localparam RESET_ST = 4'b0000,
           CHECK_KEY_ST = 4'b0001,
		   LOAD_KEY_ST = 4'b0010,
		   LOAD_NPUB_ST = 4'b0011,
		   INIT_ST = 4'b0100,
		   FINISH_INIT_ST = 4'b0101,
		   UPDATE_ST = 4'b0110,
		   PROC_ST = 4'b0111,
		   STORE_PROC_ST = 4'b1000,
		   FINISH_PROC_ST = 4'b1001, 
		   WRITE_PTCT_ST = 4'b1010, 
		   PRE_TAG_ST = 4'b1011, 
		   TAG_ST = 4'b1100,
		   LD_EXP_TAG_ST = 4'b1101, 
		   STORE_TAG_ST = 4'b1110,
		   FINISH_TAG_ST = 4'b1111; 
		   
localparam AD_TYPE = 4'b0001,
           KEY_WORDS = 3'b100,
		   NPUB_WORDS = 3'b100;
		   
always @(posedge clk)
begin
	if (rst == 1'b1) fsm_state <= RESET_ST; 
	else begin
		fsm_state <= next_fsm_state;
		if (clr_ld_ctr == 1)
		    ld_ctr <= 0;
        if (en_ld_ctr == 1)
		    ld_ctr <= ld_ctr + 1;
		if (set_bdi_complete == 1)
		    bdi_complete <= 1;
		if (reset_bdi_complete == 1)
		    bdi_complete <= 0;
		if (set_bdo_complete == 1)
		    bdo_complete <= 1;
		if (reset_bdo_complete == 1)
		    bdo_complete <= 0;
		if (set_eoi_flag == 1)
           eoi_flag <= 1;
        if (reset_eoi_flag == 1)
           eoi_flag <= 0;
        if (set_eot_flag == 1)
           eot_flag <= 1;
        if (reset_eot_flag == 1)
           eot_flag <= 0;
	    if (en_decrypt_reg == 1)
		   decrypt_reg <= decrypt;
		if (store_bdi_type == 1)
			if (bdi_type == AD_TYPE)
				bdi_type_reg <= 1;
			else
				bdi_type_reg <= 0;
		if (store_bdi_partial == 1)
			if (bdi_size[1] == 1 || bdi_size[0] ==1)
				bdi_partial_reg <= 1;
			else
				bdi_partial_reg <= 0;
	end
end

always @(fsm_state or key_update or key_valid or bdi_valid or ld_ctr or bdi_eoi or bdi_eot or perm_done or eoi_flag or
         eot_flag or bdi_complete or bdo_complete or perm_done or bdi_type_reg or bdo_ready or decrypt_reg or msg_auth_ready
		 or bdi_partial or trunc_complete)
begin

//defaults

key_ready <= 0;
en_key <= 0;
clr_ld_ctr <= 0;
en_ld_ctr <= 0;
en_npub <= 0;
en_decrypt_reg <= 0;
set_eot_flag <= 0;
reset_eot_flag <= 0;
set_eot_flag <= 0;
reset_eot_flag <= 0;
set_bdi_complete <= 0;
reset_bdi_complete <= 0;
set_bdo_complete <= 0;
reset_bdo_complete <= 0;
set_eoi_flag <= 0;
reset_eoi_flag <= 0;
bdi_ready <=0;
bdo_valid <=0;
msg_auth_valid <=0;
bdo_valid_bytes <= 4'b1111;
end_of_block <=0;
sel_tag <=0;
clr_bdi <=0;
en_bdi <=0;
start <= 0;
init_state <= 0;
init_lock <= 0;
en_state <= 0;
lock_tag_state <= 0;
ctrl_word <= 2'b0;
store_bdi_type <= 0;
store_bdi_partial <= 0;
en_cum_size <= 0;
en_trunc <= 0;
init_trunc <= 0;


	case (fsm_state)
	
	RESET_ST:
	begin
	    clr_bdi <= 1;
		en_bdi <= 1;
		en_cum_size <= 1;
		init_trunc <= 1;
		clr_ld_ctr <= 1;
		reset_eoi_flag <= 1;
		reset_eot_flag <= 1;
        reset_bdi_complete <= 1;
		reset_bdo_complete <= 1;
		store_bdi_partial <= 1;
		next_fsm_state <= CHECK_KEY_ST;	
	end
	
	CHECK_KEY_ST:
	begin
		if (key_update == 1)
		     if (key_valid == 1)
		        next_fsm_state <= LOAD_KEY_ST;
             else 
                next_fsm_state <= CHECK_KEY_ST;
         else 
		     if (bdi_valid == 1)
                next_fsm_state <= LOAD_NPUB_ST;
		     else
                next_fsm_state <= CHECK_KEY_ST;
	end
	
	LOAD_KEY_ST:
	begin
        if (key_valid == 1) begin
			key_ready <= 1;
			en_key <= 1;
            if (ld_ctr == (KEY_WORDS - 1)) begin
				clr_ld_ctr <= 1;
                next_fsm_state <= LOAD_NPUB_ST;
		    end else begin
                en_ld_ctr <= 1;
                next_fsm_state <= LOAD_KEY_ST;
            end
        end else
            next_fsm_state <= LOAD_KEY_ST;
	end

	LOAD_NPUB_ST:
	begin
	    if (bdi_valid == 1) begin
			en_npub <= 1;
            bdi_ready <= 1;
            if (ld_ctr == (NPUB_WORDS - 1)) begin
			    en_decrypt_reg <= 1; 
		        clr_ld_ctr <= 1;
			   	next_fsm_state <= INIT_ST; // one cycle delay required to lock npub
				if (bdi_eoi == 1) // no AD or PT
				    set_eoi_flag <= 1;
			end else begin
			         en_ld_ctr <= 1;
			         next_fsm_state <= LOAD_NPUB_ST;
			    end
		  end else
		    next_fsm_state <= LOAD_NPUB_ST;
	end

	INIT_ST:
	begin
		init_state <= 1;
		en_state <= 1;
		start <= 1;
		next_fsm_state <= FINISH_INIT_ST;
	end
	
	FINISH_INIT_ST:
	begin
		if (perm_done == 1) begin
			init_lock <= 1;
			en_state <= 1;
			if (eoi_flag == 1) 
				next_fsm_state <= PRE_TAG_ST;
			else begin	
				
				next_fsm_state <= UPDATE_ST;
			end
		end 
		      else next_fsm_state <= FINISH_INIT_ST;
	end
	
	UPDATE_ST:
	begin
		start <= 1;
		reset_eot_flag <= 1;
		next_fsm_state <= PROC_ST;
	end
 
 	PROC_ST:
	begin
		if (eoi_flag == 1)
			next_fsm_state <= PRE_TAG_ST;
		else 
	    
		if (bdi_valid == 1) begin
			en_bdi <= 1;
			en_cum_size <= 1;
			bdi_ready <= 1;
			store_bdi_type <= 1;
			store_bdi_partial <= 1;
			if (bdi_eot == 1)
				set_eot_flag <= 1;
			if (bdi_complete == 1) begin
				next_fsm_state <= STORE_PROC_ST;
			end else begin	
				if (bdi_eot == 1) begin
				    if (bdi_eoi == 1) 
						set_eoi_flag <= 1;
					next_fsm_state <= STORE_PROC_ST;
				end else begin
					set_bdi_complete <= 1;
					next_fsm_state <= PROC_ST;
				end
			end 
            
		end
		   else next_fsm_state <= PROC_ST;
		   
	end 

	STORE_PROC_ST:
	begin
		if (perm_done == 1) 
			next_fsm_state <= FINISH_PROC_ST;
		else	
			next_fsm_state <= STORE_PROC_ST;
	end
			
	FINISH_PROC_ST:
	begin
			if (bdi_type_reg == 1) begin
			    en_state <= 1;
				reset_bdi_complete <= 1;
				ctrl_word <= 2'b01;
				clr_bdi <= 1;
				init_trunc <= 1;
				en_cum_size <= 1;
				if (eoi_flag == 1) 
					next_fsm_state <= PRE_TAG_ST;
				else begin
					reset_eot_flag <= 1;
					next_fsm_state <= UPDATE_ST; 
				end	
			end else
				next_fsm_state <= WRITE_PTCT_ST;
	end
	
 	WRITE_PTCT_ST:
	begin
		if (bdo_ready == 1) 
	      if (trunc_complete == 1)
		  begin	
			bdo_valid <= 1;
			if (bdi_complete == 0 || bdo_complete == 1)
			begin
			    reset_bdo_complete <= 1;
				ctrl_word <= 2'b10;
				en_state <= 1;
				clr_bdi <= 1;
				init_trunc <= 1;
				en_cum_size <= 1;
				
				if (eot_flag == 1)
				begin
					end_of_block <= 1;
					next_fsm_state <= PRE_TAG_ST;
				end
				else 
				if (eoi_flag == 1)
					next_fsm_state <= PRE_TAG_ST;
				else
				begin
				    reset_bdi_complete <= 1;
					next_fsm_state <= UPDATE_ST; 
				end
			end 
			else
			begin
				set_bdo_complete <= 1;
				next_fsm_state <= WRITE_PTCT_ST;
			end
		  end else begin
		    en_trunc <= 1;
		    next_fsm_state <= WRITE_PTCT_ST;
		end 
		   else next_fsm_state <= WRITE_PTCT_ST;
	end
	
	PRE_TAG_ST:
	begin
		lock_tag_state <= 1;
		en_state <= 1;
		next_fsm_state <= TAG_ST;
	end
	
	TAG_ST:
	begin
		start <= 1;
		if (decrypt_reg == 1) begin
		    reset_bdi_complete <= 1;
			next_fsm_state <= LD_EXP_TAG_ST;
		end else
			next_fsm_state <= STORE_TAG_ST;
	end
	
	LD_EXP_TAG_ST:
	begin
		if (bdi_valid == 1) begin
			en_bdi <= 1;
			bdi_ready <= 1;
			if (bdi_complete == 1) begin
				reset_bdi_complete <= 1;
				next_fsm_state <= STORE_TAG_ST;
			end else begin
				set_bdi_complete <= 1;
				next_fsm_state <= LD_EXP_TAG_ST;
			end
		end 
		   else next_fsm_state <= LD_EXP_TAG_ST;
	end
	
	STORE_TAG_ST:
	begin
		if (perm_done == 1) 
			next_fsm_state <= FINISH_TAG_ST;
		else	
			next_fsm_state <= STORE_TAG_ST;
	end
	
	FINISH_TAG_ST:
	begin
			if (decrypt_reg == 1)
			
				if (msg_auth_ready == 1) begin
					msg_auth_valid <= 1;
					next_fsm_state <= RESET_ST;
				end 
				    else next_fsm_state <= FINISH_TAG_ST;
			
			else 
			    
			    if (bdo_ready == 1) begin
					sel_tag <= 1;
					bdo_valid <= 1;
					if (bdo_complete == 1) begin
						reset_bdo_complete <= 1;
						end_of_block <= 1;
						next_fsm_state <= RESET_ST;
					end else begin
						set_bdo_complete <= 1;
						next_fsm_state <= FINISH_TAG_ST;
					end
			    end
			         else next_fsm_state <= FINISH_TAG_ST; 
			        
	end

	default:
	begin 
		next_fsm_state <= RESET_ST; // should never get here
	end
	endcase
end

endmodule
