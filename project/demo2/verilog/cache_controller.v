module inert_intf(
	// Input from system
	clk,rst,creat_dump,
	// Input from mem
	Addr,DataIn,Rd,Wr,
	// Input from cache
	hit,dirty,tag_out,valid,
	// Input from four bank
	DataOut_mem,stall,
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

// define states
`define IDLE 4'b0000;
`define HIT 4'b0001;
`define CMP_RD_0 4'b0010;
`define CMP_WT_0 4'b0011;
`define ACC_RD_0 4'b0100;
`define ACC_RD_1 4'b0101;
`define ACC_RD_2 4'b0110;
`define ACC_RD_3 4'b0111;
`define ACC_WT_0 4'b1000;
`define ACC_WT_1 4'b1001;
`define ACC_WT_2 4'b1010;
`define ACC_WT_3 4'b1011;
`define ACC_WT_4 4'b1100;
`define ACC_WT_5 4'b1101;
`define CMP_WT_1 4'b1110;
`define CMP_RD_1 4'b1111;

// ff for state machine
wire [3:0] state, next_state, state_q;
dff state_fsm(.q(state_q), .d(next_state), .clk(clk), .rst(rst));
assign state = rst ? IDLE : state_q;

wire err_fsm;
// FSM
always @* 
	begin
		enable_ct = 1'b1;
		index_cache = 8'bxxxx_xxxx;
		offset_cache = 3'bxxx
		cmp_ct = 1'b0;
		wr_cache = 1'b0;
		tag_cache = 5'bxxxx_x;
		DataIn_ct = 
		valid_in_ct = 1'b0;
		Addr_mem = 
		DataIn_mem = 
		wr_mem = 1'b0;
		rd_mem = 1'b0;
		Done = 1'b0;
		CacheHit = 1'b0;
		Stall_sys = 1'b1;

		case(state)
			default: // default case, rise an error
				err_fsm = 1;
			IDLE:
				begin
					Stall_sys = 0;
					next_state = Rd ? (CMP_RD_0) : ()
		endcase
	end



// state machine body
always_comb begin
    next_state = state;
    wrt = 0;
    done = 0;
    cmd = 16'b0;
    vld = 0;
    C_R_H = 0;
    C_R_L = 0;
    C_Y_H = 0;
    C_Y_L = 0;
    C_AY_H = 0;
    C_AY_L = 0;
    C_AZ_H = 0;
    C_AZ_L = 0;

    case(state)
        EXPIRE:
            if(&timer)begin
                next_state = INIT_0;
		cmd = 16'h0D02;
		wrt = 1;
	    end
	// 0x0D02 enable interrupt upon data ready
	INIT_0:          
	    if(done)begin
		next_state = INIT_1;
		cmd = 16'h1053;
		wrt = 1;
	    end
	// 0x1053 setup accel
	INIT_1:
	    if(done)begin   
		next_state = INIT_2;
		cmd = 16'h1150;
		wrt = 1;
	    end
	// 0x1150 setup gyro
	INIT_2:
	    if(done)begin 
		next_state = INIT_3;
		cmd = 16'h1460;
		wrt = 1;
	    end
	// 0x1460 setup gyro
	INIT_3:
	    if(done)
		next_state = INF;

	INF:
	    if(init == 1)begin
		next_state = READ_rL;
		cmd = 16'hA400; // TODO: whether xx save area?
		wrt = 1;
	    end
	
	READ_rL:
	    if(done) begin
		next_state = READ_rH;
		cmd = 16'hA500;
	 	wrt = 1;
		C_R_L = 1;
	    end

	READ_rH:
	    if(done) begin
		next_state = READ_yL;
		cmd = 16'hA600;
	 	wrt = 1;
		C_R_H = 1;
	    end
	
	READ_yL:
	    if(done) begin
		next_state = READ_yH;
		cmd = 16'hA700;
	 	wrt = 1;
		C_Y_L = 1;
	    end

	READ_yH:
	    if(done) begin
		next_state = READ_AYL;
		cmd = 16'hAA00;
	 	wrt = 1;
		C_Y_H = 1;
	    end

	READ_AYL:
	    if(done) begin
		next_state = READ_AYH;
		cmd = 16'hAB00;
	 	wrt = 1;
		C_AY_L = 1;
	    end

	READ_AYH:
	    if(done) begin
		next_state = READ_AZL;
		cmd = 16'hAC00;
	 	wrt = 1;
		C_AY_H = 1;
	    end

	READ_AZL:
	    if(done) begin
		next_state = READ_AZH;
		cmd = 16'hAD00;
	 	wrt = 1;
		C_AZ_L = 1;
	    end

	READ_AZH:
	    if(done) begin
		next_state = VAL;
		C_AZ_H = 1;
	    end

	VAL: 
	    begin
	        vld = 1;
	        next_state = INF;
	    end
    endcase
end


endmodule