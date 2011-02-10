//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:32:35 09/16/2010 
// Module Name:    FSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Finite State Machine to control the functionality of the autocorellation module.
//						 Modeled after the "autocorr" fuction of the C-code.					 
// 
// Dependencies: 	 hammingWindowMemory.v, twoway_32bit_mux.v, reg_Q31withReset.v,twoway_16bit_mux.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module autocorrFSM(clk, reset, ready,xIn,memIn,L_shlDone,norm_lDone,L_shlIn,L_shrIn,shrIn,addIn,subIn,
						overflow,norm_lIn,multIn,L_macIn,L_macOutA,L_macOutB,L_macOutC,norm_lVar1Out,multOutA,
						multOutB,multRselOut,L_shlReady,L_shlVar1Out,L_shlNumShiftOut,L_shrVar1Out,L_shrNumShiftOut,
						shrVar1Out,shrVar2Out,addOutA,addOutB,subOutA,subOutB,norm_lReady,norm_lReset,
						writeEn,xRequested,readRequested,writeRequested,memOut,done);
//inputs 
`include "paramList.v"
input clk, reset,ready;
input signed [15:0] xIn;
input signed [31:0] memIn;
input L_shlDone,norm_lDone;
input [31:0] L_shlIn;
input [31:0] L_shrIn;
input [15:0] shrIn;
input [15:0] addIn;
input [15:0] subIn;
input overflow;
input [15:0] norm_lIn;
input signed [15:0] multIn;
input [31:0] L_macIn;

//outputs
output [15:0] L_macOutA,L_macOutB;
output [31:0] L_macOutC;
output signed [31:0] norm_lVar1Out;
output [15:0] multOutA,multOutB;
output multRselOut;
output reg norm_lReady, norm_lReset;
output reg L_shlReady;
output [31:0] L_shlVar1Out; 
output [15:0] L_shlNumShiftOut;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] addOutA,addOutB;
output reg [15:0] subOutA,subOutB;
output reg writeEn;
output reg [7:0] xRequested;
output reg [10:0] writeRequested,readRequested;
output [31:0] memOut;
output reg done;

//working regs

reg mux1sel;
reg R0_ld,R0_reset,R0_resetToOne;
reg signed [15:0] xi;
reg signed [15:0] memYreg;
reg [15:0] yi,yiplusj;
reg mux0sel;
reg memYregld;
reg norm_lDoneReg,L_shlDoneReg;
reg norm_lDoneReset,L_shlDoneReset;
reg overflowReg, overflowReset,overflowLD;
reg [4:0] state,nextstate;
reg [7:0] count1,count2,count3,count4,count5;
reg [7:0] nextcount1,nextcount2,nextcount3,nextcount4,nextcount5;
reg count1ld,count2ld,count3ld,count4ld,count5ld;
reg count1reset,count2reset,count3reset,count4reset,count5reset;
reg signed [31:0] memOut;
reg signed [15:0] rHigh,rLow,rLowTemp;  
reg [7:0] hamIn;

//working wires
wire [15:0] hamOut;
wire [31:0] mux1out;
wire [15:0] mux0out;
wire signed [31:0] sum;
assign L_macOutA = yi;
assign L_macOutB = mux0out;
assign L_macOutC = sum;
assign multOutA = xi;
assign multOutB = hamOut;
assign norm_lVar1Out = sum;
assign L_shlVar1Out = norm_lVar1Out;
assign L_shlNumShiftOut = norm_lIn;
assign multRselOut = 1;

//State parameters
parameter M = 8'd10;				//M is a constant defined in the ld8k.h file
parameter L_WINDOW = 8'd240;		//L_WINDOW is a constant defined in the ld8k.h file
parameter INIT = 5'd0;
parameter S1 = 5'd1;
parameter MEM_WAIT_1 = 5'd2;
parameter MEM_READ1 = 5'd3;
parameter S2 = 5'd4;
parameter MEM_READ2 = 5'd5;
parameter MEM_READ3 = 5'd6;
parameter S3 = 5'd7;
parameter MEM_R_WRITE = 5'd8;
parameter S4 = 5'd9;
parameter S5 = 5'd10; 
parameter MEM_READ4 = 5'd11;
parameter MEM_READ5 = 5'd12;
parameter MEM_READ6 = 5'd13;
parameter MEM_R_WRITE1 = 5'd14;

//Instantiated modules
hammingWindowMemory hamMem(
									.in(hamIn),									
									.out(hamOut)
									);	
twoway_32bit_mux mux1(
							.in0(L_macIn),
							.in1(L_shlIn),
							.sel(mux1sel),
							.out(mux1out));	
reg_Q31withReset R0(
							.mclk(clk),
							.reset(reset||R0_reset),
							.resetToOne(R0_resetToOne),
							.ld(R0_ld),
							.d(mux1out),
							.q(sum));							

twoway_16bit_mux mux0(
							.in0(yi),
							.in1(yiplusj),
							.sel(mux0sel),
							.out(mux0out)
							);						

//state D-flip-flop
always@(posedge clk) begin
	if(reset)
		 state <= INIT;
	else
		 state <= nextstate;
end

//count1 incrementer always block
always@(posedge clk) begin
	if(reset||count1reset)
		 count1 <= 0;
	else if(count1ld)
		 count1 <= nextcount1;
end

//count2 incrementer always block
always@(posedge clk) begin
	if(reset||count2reset)
		 count2 <= 0;
	else if(count2ld)
		 count2 <= nextcount2;
end

//count3 incrementer always block
always@(posedge clk) begin
	if(reset||count3reset)
		 count3 <= 0;
	else if(count3ld)
		 count3 <= nextcount3;
end

//count4 incrementer always block
always@(posedge clk) begin
	if(reset||count4reset)
		 count4 <= 0;
	else if(count4ld)
		 count4 <= nextcount4;
end

//count5 incrementer always block
always@(posedge clk) begin
	if(reset||count5reset)
		 count5 <= 0;
	else if(count5ld)
		 count5 <= nextcount5;
end

//y memory read always block
always@(posedge clk) begin
	if(reset)	 
		 memYreg <= 0;
	else if (memYregld)
	    memYreg <= memIn[15:0];
end

//normalizer done flop
always@(posedge clk) begin
	if(reset)	 
		 norm_lDoneReg <= 0;
	else if (norm_lDoneReset)
		norm_lDoneReg <= 0;
	else if (norm_lReady)
	    norm_lDoneReg <= norm_lDone;
end

//left shifter done flop
always@(posedge clk) begin
	if(reset)	 
		 L_shlDoneReg <= 0;
	else if (L_shlDoneReset)
		L_shlDoneReg <= 0;
	else if (L_shlReady)
	    L_shlDoneReg <= L_shlDone;
end

//overflow flop
always@(posedge clk) begin
	if(reset)	 
		 overflowReg <= 0;
	else if(overflowReset)
		overflowReg <= 0;
	else if (overflowLD)
	    overflowReg <= 1;
end

always@(negedge clk)
begin
	if(overflow)
		overflowLD = 1;
	else if(overflow != 1)
		overflowLD = 0;
end

//state machine always block
always @(*) begin	
	done = 0;
	R0_ld = 0;
	R0_reset = 0;
	R0_resetToOne = 0;
	count1ld = 0;
	count2ld = 0;
	count3ld = 0;
	count4ld = 0;
	count5ld = 0;
	count1reset = 0;
	count2reset = 0;
	count3reset = 0;
	count4reset = 0;
	count5reset = 0;
	mux0sel = 0;
	mux1sel = 0;
	norm_lReady = 0;
	L_shlReady = 0;
	writeEn = 0;
	nextstate = state;
	nextcount1 = count1;
	nextcount2 = count2;
	nextcount3 = count3;
	nextcount4 = count4;
	nextcount5 = count5;
	norm_lDoneReset = 0;
	L_shlDoneReset = 0;
	overflowReset = 0;
	norm_lReset = 0;
	hamIn = 0;
	xi = 0;
	yi = 0;
	yiplusj = 0;	
	xRequested = 0;
	//readRequested = 0;
	writeRequested = 0;
	//rRequested = 0;
	memOut = 0;
	memYregld = 0;	
	/*norm_lVar1Out = 0;
	multOutA = 0;
	multOutB = 0;
	multRselOut = 0;
   L_shlReady = 0;
	L_shlVar1Out = 0; 
	L_shlNumShiftOut = 0;
	L_shrVar1Out = 0;
	L_shrNumShiftOut = 0;
	shrVar1Out = 0;
	shrVar2Out = 0;
	addOutA = 0;
	addOutB = 0;
	subOutA = 0;
	subOutB = 0;
	memOut = 0;
*/
	case(state)
	
	INIT: begin		//state 0
	done = 0;
	count1reset = 1;
	count2reset = 1;
	count3reset = 1;
	count4reset = 1;
	count5reset = 1;	
	norm_lDoneReset = 1;
	L_shlDoneReset = 1;
	//R0_resetToOne = 1;
	
	if(ready == 0)	//waits on a ready signal from the top level
		nextstate = INIT;
	else if(ready == 1)
		nextstate = S1;
	end//end INIT
	
	S1: begin		//state 1
		norm_lReset = 1;
		if(count1 >= L_WINDOW)
		begin
			nextstate = S2;
			R0_resetToOne = 1;
		end
		else if(count1 <= L_WINDOW) begin				
			xRequested = count1;    //tells the memory module which x is requested	      			
			nextstate = MEM_WAIT_1;
		end //end if
		
	end //end S1
	
	MEM_WAIT_1:		//state 2
	begin
		xRequested = count1;    //tells the memory module which x is requested
		nextstate = MEM_READ1;
	end	

	MEM_READ1:	//state 3
	begin
		xi = xIn;
		hamIn = count1;		//read from hammingWindow memory			
		xRequested = count1;
		writeRequested = {AUTOCORR_Y[10:8],count1[7:0]};			//tells the memory module which y is requested
		memOut = {16'd0,multIn[15:0]};	//write from reg multIn to memory y[count1]
		writeEn = 1;	//set memory writing high			
		nextstate = S1;
		addOutA = count1;
		addOutB = 16'd1;
		nextcount1 = addIn;
		count1ld = 1;		//start incrementing this count variable
	end			

	S2: begin	//state 4
			
			if(count2 >= L_WINDOW) begin //if1	
				if(overflowReg ==0)
					nextstate = S3;					
				else
				begin // else1
				
					if (count3 >= L_WINDOW) //if2 
					begin
						if(overflowReg == 0)
							nextstate = S3;
						else if(overflowReg != 0)
						begin					//if3
							nextstate = S2;
							count2reset = 1;
							count3reset = 1;
							R0_resetToOne = 1;
							overflowReset = 1;
						end				//if3
					end//if2
					else if(count3 < L_WINDOW) 
					begin //if4				
						readRequested = {AUTOCORR_Y[10:8],count3[7:0]};	//tells the memory module which y is requested
						nextstate = MEM_READ3;//nextstate = MEM_WAIT_4;
					end//if4
				end //else1 
			end //end if1
		
		else if(count2 < L_WINDOW) begin //else1	
			mux1sel = 0;			
			readRequested = {AUTOCORR_Y[10:8],count2[7:0]};			//tells the memory module which y is requested			
			nextstate = MEM_READ2;//nextstate = MEM_WAIT_3;			
		end //end else1

	end //end S2	

	MEM_READ2: begin	//state 5
		readRequested = {AUTOCORR_Y[10:8],count2[7:0]};		//tells the memory module which y is requested
		yi = memIn[15:0]; //read from y[count2] to reg yi							
		R0_ld = 1;
		nextstate = S2;
		addOutA = count2;
		addOutB = 16'd1;
		nextcount2 = addIn;
		count2ld = 1;		//start incrementing this count variable
	end //end mem_read2
	
	MEM_READ3: begin	//state 6
		readRequested = {AUTOCORR_Y[10:8],count3[7:0]};		//tells the memory module which y is requested
		shrVar1Out = memIn[15:0];
		shrVar2Out = 16'd2;
		yi = shrIn;
		memOut = {16'd0,yi[15:0]};	
		writeRequested = {AUTOCORR_Y[10:8],count3[7:0]};
		writeEn = 1;		//read from yi back into y[count2]	
		addOutA = count3;
		addOutB = 16'd1;
		nextcount3 = addIn;
		count3ld = 1;	//start incrementing this count variable		
		nextstate = S2;
	end //end mem_read3	
	
	S3: begin	//state 7
		mux1sel = 1;		
		if((norm_lDoneReg == 0) && (L_shlDoneReg == 0))
		begin	//if1
			nextstate = S3;
			norm_lReady = 1;
		end//if1
		else if(norm_lDoneReg == 1) 
		begin //else1
			norm_lReady = 0;
			L_shlReady = 1;
			
			if(L_shlDoneReg == 0)
				nextstate = S3;
			else begin //else2
				L_shlReady = 0;
				R0_ld = 1;
				nextstate = MEM_R_WRITE;
			end //else2
		end//else 1
	
	end//end S3
	
	MEM_R_WRITE: 	//state 8
	begin
		writeRequested = {AUTOCORR_R[10:8],8'd0};
		rHigh = sum[31:16]; 	
		L_shrVar1Out = sum[15:0];
		L_shrNumShiftOut = 32'd1;
		rLow = L_shrIn[15:0];
		memOut = {rHigh,rLow};
		writeEn = 1;	//write r'(0) to memory
		nextstate = S4;
	end
	
	S4: begin	//state 9	
		
		if(count4 >= M) 
		begin //if 1
			nextstate = INIT;
			done = 1;
		end//end if1
		
		 else if(count4 < M)
		 begin //else1
			nextstate = S5;
			addOutA = count4;
			addOutB = 16'd1;
			nextcount4 = addIn;
			count4ld = 1;		//start incrementing this count variable
			count5reset = 1;
			R0_reset = 1;
			L_shlDoneReset = 1;
		end//end else1			
		
	end //end S4	
	
	S5: begin		//state 10
		subOutA = L_WINDOW;
      subOutB = count4;		
		if(count5 >= subIn[7:0]) 
		begin//if1
			L_shlReady = 1;
			mux1sel = 1;
			if(L_shlDoneReg == 0)
				nextstate = S5;
			else 
			begin //else1
				R0_ld = 1;
				nextstate = MEM_R_WRITE1;
			end //end else1
		end //if1			
			
		else if(count5 < subIn[7:0]) 
		begin //if2	
			mux1sel = 0;
			readRequested = {AUTOCORR_Y[10:8],count5[7:0]};			//request y[count5]			
			nextstate = MEM_READ4;//nextstate = MEM_WAIT_5;
		end//if2		
	
	end//end S5	

	MEM_READ4:  	//state 11
	begin	
		memYregld = 1;
		addOutA = count4;
		addOutB = count5;
		readRequested = {AUTOCORR_Y[10:8],addIn[7:0]};			//request y[count4+count5]	
		nextstate = MEM_READ5;
	end//end mem_read4
	
	MEM_READ5: 		//state 12
	begin
		addOutA = count4;
		addOutB = count5;
		readRequested = {AUTOCORR_Y[10:8],addIn[7:0]};			//request y[count4+count5]	
		nextstate = MEM_READ6;
	end //end mem_read5
	
	MEM_READ6: 		//state 13
	begin		
		yiplusj = memIn[15:0];//read from y[count4+count5] to reg yiPlusJ
		mux0sel = 1;
		yi = memYreg;	//read from y[count5] to reg yi		
		R0_ld = 1;
		addOutA = count5;
		addOutB = 16'd1;
		nextcount5 = addIn;
		count5ld = 1;		//start incrementing this count variable
		nextstate = S5;
	end //end mem_read5
	
	MEM_R_WRITE1: 	//state 14
	begin
		writeRequested = {AUTOCORR_R[10:8],count4[7:0]};
		rHigh = sum[31:16];
		L_shrVar1Out = sum[15:0];
		L_shrNumShiftOut = 32'd1;
		rLow = L_shrIn[15:0];
		memOut = {rHigh,rLow};
		writeEn = 1;	//write r'(n) to memory
		R0_reset = 0;
		nextstate = S4;		
	end
	
	default:
		nextstate = INIT;
	
	endcase
end //end always

endmodule