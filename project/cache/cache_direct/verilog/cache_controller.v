module cache_controller(
	// Input from system
	clk,rst,creat_dump,
	// Input from mem
	Addr,DataIn,Rd,Wr,
	// Input from cache
	hit,dirty,tag_out,DataOut_cache,valid,
	// Input from four bank
	DataOut_mem,
	// Output to cache
	enable_ct,index_cache,
	offset_cache,cmp_ct,
	wr_cache,tag_cache,
	DataIn_ct,valid_in_ct,
	// Output to fourbank
	Addr_mem,DataIn_mem,
	wr_mem,rd_mem,
	// Output to system
	Done,CacheHit,Stall_sys
);

// Input, output
input clk, rst, creat_dump, Wr, Rd, hit, dirty, valid;
input [15:0] Addr, DataIn, DataOut_mem, DataOut_cache;
input [4:0] tag_out;

output reg enable_ct, cmp_ct, wr_cache, valid_in_ct, wr_mem, rd_mem, Done, CacheHit, Stall_sys;
output reg[15:0] DataIn_ct, Addr_mem, DataIn_mem;
output reg[7:0] index_cache;
output reg[2:0] offset_cache;
output reg[4:0] tag_cache;


// define states
localparam IDLE = 4'b0000;
localparam HIT = 4'b0001;
localparam CMP_RD_0 = 4'b0010;
localparam CMP_WT_0 = 4'b0011;
localparam ACC_RD_0 = 4'b0100;
localparam ACC_RD_1 = 4'b0101;
localparam ACC_RD_2 = 4'b0110;
localparam ACC_RD_3 = 4'b0111;
localparam ACC_WT_0 = 4'b1000;
localparam ACC_WT_1 = 4'b1001;
localparam ACC_WT_2 = 4'b1010;
localparam ACC_WT_3 = 4'b1011;
localparam ACC_WT_4 = 4'b1100;
localparam ACC_WT_5 = 4'b1101;
localparam CMP_WT_1 = 4'b1110;
localparam CMP_RD_1 = 4'b1111;

// ff for state machine
wire err_reg;
wire [3:0] state, state_q;
reg [3:0] next_state;
reg_16 #(.SIZE(4)) state_fsm(.readData(state_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(next_state), .writeEn(1'b1));
assign state = rst ? IDLE : state_q;

reg err_fsm;
// FSM
always @* 
	begin
		enable_ct = 1'b0;
		index_cache = 8'bxxxx_xxxx;
		offset_cache = 3'bxxx;
		cmp_ct = 1'b0;
		wr_cache = 1'b0;
		tag_cache = 5'bxxxx_x;
		DataIn_ct = 16'bxxxx_xxxx_xxxx_xxxx;
		valid_in_ct = 1'b0;
		Addr_mem = 16'bxxxx_xxxx_xxxx_xxxx;
		DataIn_mem = 16'bxxxx_xxxx_xxxx_xxxx; 
		wr_mem = 1'b0;
		rd_mem = 1'b0;
		Done = 1'b0;
		CacheHit = 1'b0;
		Stall_sys = 1'b1;
		err_fsm = 1'b0;

		case(state)
			default: err_fsm = 1'b1;
			IDLE:
				begin
					Stall_sys = 1'b0;
					next_state = Rd ? (CMP_RD_0) : (Wr ? (CMP_WT_0) : (state));
				end
			CMP_RD_0:
				begin
					enable_ct = 1'b1;
					cmp_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = Addr[2:0];
					tag_cache = Addr[15:11];
					next_state = hit ? (valid ? (HIT) : (ACC_WT_0)) : (dirty ? (valid ? (ACC_RD_0) : (ACC_WT_0)) : (ACC_WT_0));
				end
			CMP_WT_0:
				begin
					enable_ct = 1'b1;
					cmp_ct = 1'b1;
					wr_cache = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = Addr[2:0];
					tag_cache = Addr[15:11];
					next_state = hit ? (valid ? (HIT) : (ACC_WT_0)) : (dirty ? (valid ? (ACC_RD_0) : (ACC_WT_0)) : (ACC_WT_0));
				end
			HIT:
				begin
					enable_ct = 1'b1;
					Done = 1'b1;
					CacheHit = 1'b1;
					next_state = IDLE;
				end
			ACC_RD_0:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b000;
					Addr_mem = {Addr[15:8],tag_out,3'b000};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_1;
				end
			ACC_RD_1:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b010;
					Addr_mem = {Addr[15:8],tag_out,3'b010};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_2;
				end
			ACC_RD_2:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b100;
					Addr_mem = {Addr[15:8],tag_out,3'b100};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_3;
				end
			ACC_RD_3:
				begin
					enable_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b110;
					Addr_mem = {Addr[15:8],tag_out,3'b110};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_WT_0;
				end
			ACC_WT_0:
				begin
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b000};
					next_state = ACC_WT_1;
				end
			ACC_WT_1:
				begin
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b010};
					next_state = ACC_WT_2;
				end
			ACC_WT_2:
				begin
				    // read from mem
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b100};
					// wrt to cache
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b000;
					tag_cache = Addr[15:11];
					DataIn_ct = DataOut_mem;
					next_state = ACC_WT_3;
				end
			ACC_WT_3:
				begin
				    // read from mem
					enable_ct = 1'b1;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b110};
					// wrt to cache
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b010;
					tag_cache = Addr[15:11];
					DataIn_ct = DataOut_mem;
					next_state = ACC_WT_4;
				end
			ACC_WT_4:
				begin
					// wrt to cache
					enable_ct = 1'b1;
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b100;
					tag_cache = Addr[15:11];
					DataIn_ct = DataOut_mem;
					next_state = ACC_WT_5;
				end
			ACC_WT_5:
				begin
					// wrt to cache
					enable_ct = 1'b1;
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b110;
					tag_cache = Addr[15:11];
					DataIn_ct = DataOut_mem;
					next_state = Rd ? (CMP_RD_1) : (Wr ? (CMP_WT_1) : IDLE);
				end
			CMP_RD_1:
				begin
					enable_ct = 1'b1;
					cmp_ct = 1'b1;
					wr_cache = 1'b0;
					index_cache = Addr[10:3];
					offset_cache = Addr[2:0];
					tag_cache = Addr[15:11];
					Done = 1'b1;
					next_state = IDLE;
				end
			CMP_WT_1:
				begin
					enable_ct = 1'b1;
					cmp_ct = 1'b1;
					wr_cache = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = Addr[2:0];
					tag_cache = Addr[15:11];
					Done = 1'b1;
					next_state = IDLE;
				end
		endcase
	end

//////////////////////////////////////////////////////////////////

endmodule