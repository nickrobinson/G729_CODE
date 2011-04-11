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
						overflow,norm_lIn,multIn,L_macIn,L_msuIn,L_macOutA,L_macOutB,L_macOutC,L_msuOutA,
						L_msuOutB,L_msuOutC,norm_lVar1Out,multOutA,multOutB,multRselOut,L_shlReady,L_shlVar1Out,
						L_shlNumShiftOut,L_shrVar1Out,L_shrNumShiftOut,shrVar1Out,shrVar2Out,addOutA,addOutB,
						subOutA,subOutB,norm_lReady,norm_lReset,writeEn,xRequested,readRequested,writeRequested,
						memOut,done);
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
input [31:0] L_msuIn;

//outputs
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [31:0] norm_lVar1Out;
output reg [15:0] multOutA,multOutB;
output multRselOut;
output reg norm_lReady, norm_lReset;
output reg L_shlReady;
output reg[31:0] L_shlVar1Out; 
output reg [15:0] L_shlNumShiftOut;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] addOutA,addOutB;
output reg [15:0] subOutA,subOutB;
output reg writeEn;
output reg [7:0] xRequested;
output reg [11:0] writeRequested,readRequested;
output reg [31:0] memOut;
output reg done;

//working regs
reg [4:0] state,nextstate;
reg [15:0] i, nexti;
reg iLD,iReset;
reg [15:0] j,nextj;
reg jLD,jReset;
reg [15:0] norm,nextnorm;
reg normLD,normReset;
reg [31:0] sum,nextsum;
reg sumLD,sumReset;
reg [31:0] temp,nexttemp;
reg tempLD,tempReset;
reg overflowReg;
reg overflowLD,overflowReset;
reg [7:0] hamIn;

//working wires
wire [15:0] hamOut;

//State parameters
parameter INIT = 5'd0;
parameter S1 = 5'd1;
parameter S2 = 5'd2;
parameter S3 = 5'd3;
parameter S4 = 5'd4;
parameter S5 = 5'd5;
parameter S6 = 5'd6;
parameter S7 = 5'd7;
parameter S8 = 5'd8;
parameter S9 = 5'd9;
parameter S10 = 5'd10;
parameter S11 = 5'd11;
parameter S12 = 5'd12;
parameter S13 = 5'd13;
parameter S14 = 5'd14;
parameter S15 = 5'd15;
parameter S16 = 5'd16;
parameter S17 = 5'd17;
parameter S18 = 5'd18;
parameter S19 = 5'd19;
parameter S20 = 5'd20;
parameter S21 = 5'd21;
parameter S22 = 5'd22;
parameter S23 = 5'd23;
parameter S24 = 5'd24;
parameter S25 = 5'd25;
parameter S26 = 5'd26;
parameter S27 = 5'd27;
parameter S28 = 5'd28;
parameter S29 = 5'd29;

assign multRselOut = 1;

//Instantiated modules
hammingWindowMemory hamMem(
									.in(hamIn),									
									.out(hamOut)
									);	
				

//state D-flip-flop
always@(posedge clk) begin
	if(reset)
		 state <= INIT;
	else
		 state <= nextstate;
end

always@(posedge clk) begin
	if(reset)
		 i <= 0;
	else if(iReset)
		 i <= 0;
	else if(iLD)
		 i <= nexti;
end

always@(posedge clk) begin
	if(reset)
		 j <= 0;
	else if(jReset)
		 j <= 0;
	else if(jLD)
		 j <= nextj;
end

always@(posedge clk) begin
	if(reset)
		 norm <= 0;
	else if(normReset)
		 norm <= 0;
	else if(normLD)
		 norm <= nextnorm;
end

always@(posedge clk) begin
	if(reset)
		 sum <= 0;
	else if(sumReset)
		 sum <= 0;
	else if(sumLD)
		 sum <= nextsum;
end

always@(posedge clk) begin
	if(reset)
		 temp <= 0;
	else if(tempReset)
		 temp <= 0;
	else if(tempLD)
		 temp <= nexttemp;
end

always@(posedge clk) begin
	if(reset)
		 overflowReg <= 0;
	else if(overflowReset)
		 overflowReg <= 0;
	else if(overflowLD)
		 overflowReg <= 1;
end

always @(negedge clk)
begin

	if(overflow == 1)
		overflowLD = 1;		
	else if(overflow != 1)
		overflowLD = 0;
end

//state machine always block
always @(*) begin	
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	L_msuOutA = 0;
	L_msuOutB = 0;
	L_msuOutC = 0;
	norm_lVar1Out = 0;
	multOutA = 0;
	multOutB = 0;
	norm_lReady = 0;
	norm_lReset = 0;
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
	writeEn = 0;
	xRequested = 0;
	writeRequested = 0;
	readRequested = 0;
	memOut = 0;
	done = 0;
	nextstate = state;
	nexti = i;
	nextj = j;
	nextnorm = norm;
	nextsum = sum;
	nexttemp = temp;
	iLD = 0;
	jLD = 0;
	normLD = 0;
	sumLD = 0;
	tempLD = 0;
	iReset = 0;
	jReset = 0;
	normReset = 0;
	sumReset = 0;
	tempReset = 0;
	overflowReset = 0;
	hamIn = 0;
	
	case(state)
	
	INIT: begin	
		if(ready == 0)
			nextstate = INIT;
		else if(ready == 1)
		begin		
			iReset = 1;
			jReset = 1;
			normReset = 1;
			sumReset = 1;
			tempReset = 1;
			overflowReset = 1;
			nextstate = S1;
		end
	end//INIT
	
	//for(i=0; i<L_WINDOW; i++)
	S1:
	begin
		if(i>=240)
			nextstate = S3;
		else if(i<240)
		begin
			xRequested = i[7:0];
			nextstate = S24;
		end
	end//S1
	
	S24:
	begin
		xRequested = i[7:0];
		nextstate = S2;
	end//S24
	//y[i] = mult_r(x[i], hamwindow[i]);
	S2:
	begin
		xRequested = i[7:0];
		hamIn = i[7:0];
		multOutA = xIn;
		multOutB = hamOut;		
		writeRequested = {AUTOCORR_Y[11:8],i[7:0]}; 
		writeEn = 1;
		memOut = multIn;
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S1;
	end//S2
	
	/* do {
    Overflow = 0;
    sum = 1;*/
	S3:
	begin
		overflowReset = 1;
		nextsum = 1;
		sumLD = 1;
		iReset = 1;
		nextstate = S4;
	end//S3
	
	//for(i=0; i<L_WINDOW; i++){
	S4:
	begin
		if(i>=240)
			nextstate = S6;
		else if(i<240)
		begin
			readRequested = {AUTOCORR_Y[11:8],i[7:0]};
			nextstate = S5;
		end
	end//S4
	
	//sum = L_mac(sum, y[i], y[i]);
	S5:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = memIn[15:0];
		L_macOutC = sum;
		nextsum = L_macIn;
		sumLD = 1;
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S4;
	end//S5
	
	//if(Overflow != 0)
	S6:
	begin
		if(overflowReg == 1)
		begin
			iReset = 1;
			nextstate = S7;
		end
		else if(overflowReg == 0)
			nextstate = S9;
	end//S6
	
	//for(i=0; i<L_WINDOW; i++)
	S7:
	begin
		if(i>=240)
			nextstate = S9;
		else if(i<240)
		begin
			readRequested = {AUTOCORR_Y[11:8],i[7:0]};
			nextstate = S8;
		end
	end//S7
	
	//y[i] = shr(y[i], 2);
	S8:
	begin
		shrVar1Out = memIn[15:0];
		shrVar2Out = 16'd2;
		memOut = shrIn[15:0];
		writeEn = 1;
		writeRequested = {AUTOCORR_Y[11:8],i[7:0]};
		addOutA = i;
		addOutB = 16'd1;
		iLD = 1;
		nexti = addIn;
		nextstate = S7;
	end//S8
	
	//while (Overflow != 0);
	S9:
	begin
		if(overflowReg == 1)
			nextstate = S3;
		else if(overflowReg == 0)
			nextstate = S10;
	end//S9
	
	//norm = norm_l(sum);
	S10:
	begin
		norm_lVar1Out = sum;
		norm_lReady = 1;
		if(norm_lDone == 1)
		begin
			nextnorm = norm_lIn;
			normLD = 1;
			nextstate = S12;
		end
		else
			nextstate = S11;
	end//S10
	
	//norm = norm_l(sum);
	S11:
	begin
		norm_lVar1Out = sum;
		if(norm_lDone == 0)
			nextstate = S11;
		else if (norm_lDone == 1)
		begin
			nextnorm = norm_lIn;
			normLD = 1;
			nextstate = S12;
		end
	end//S11
	
	//sum  = L_shl(sum, norm);
	S12:
	begin
		L_shlVar1Out = sum;
		L_shlNumShiftOut = norm;
		L_shlReady = 1;
		if(L_shlDone == 1)
		begin
			nextsum = L_shlIn;
			sumLD = 1;
			nextstate = S14;
		end
		else
			nextstate = S13;
	end//S12
	
	S13:
	begin
		L_shlVar1Out = sum;
		L_shlNumShiftOut = norm;
		if(L_shlDone == 0)
			nextstate = S13;
		else if(L_shlDone == 1)
		begin
			nextsum = L_shlIn;
			sumLD = 1;
			nextstate = S14;
		end		
	end//S13
	
	// L_Extract(sum, &r_h[0], &r_l[0]); 
	S14:
	begin
		L_shrVar1Out = sum;
		L_shrNumShiftOut = 32'd1;
		nexttemp = L_shrIn;
		tempLD = 1;
		nextstate = S15;
	end//S14
	
	//L_Extract(sum, &r_h[0], &r_l[0]); 
	S15:
	begin
		L_msuOutA = sum[31:16];
		L_msuOutB = 16'd16384;
		L_msuOutC = temp;
		memOut = {sum[31:16],L_msuIn[15:0]};
		writeEn = 1;
		writeRequested = AUTOCORR_R;
		nexti = 1;
		iLD = 1;		
		nextstate = S16;
	end//S15
	
	//for (i = 1; i <= m; i++)
	S16:
	begin
		if(i>10)
		begin
			nextstate = INIT;
			done = 1;
		end
		else if(i<=10)
		begin
			sumReset = 1;
			nextstate = S17;
			jReset = 1;
		end
	end//S16	
	
	//for(j=0; j<L_WINDOW-i; j++)
	S17:
	begin
		subOutA = 16'd240;
		subOutB = i;
		if(j>=subIn)
			nextstate = S20;
		else if(j<subIn)
		begin
			addOutA = j;
			addOutB = i;
			readRequested = {AUTOCORR_Y[11:8],addIn[7:0]};
			nextstate = S18;
		end	
	end//S17
	
	S18:
	begin
		nexttemp = memIn;
		tempLD = 1;
		readRequested = {AUTOCORR_Y[11:8],j[7:0]};
		nextstate = S19;
	end//S18
	
	//sum = L_mac(sum, y[j], y[j+i]);
	S19:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = sum;
		nextsum = L_macIn;
		sumLD = 1;
		addOutA = j;
		addOutB = 16'd1;
		nextj = addIn;
		jLD = 1;
		nextstate = S17;
	end//S19
	
	//sum = L_shl(sum, norm);
	S20:
	begin
		L_shlVar1Out = sum;
		L_shlNumShiftOut = norm;
		L_shlReady = 1;
		if(L_shlDone == 1)
		begin
			nextsum = L_shlIn;
			sumLD = 1;
			nextstate = S22;
		end
		else
			nextstate = S21;
	end//S20
	
	//sum = L_shl(sum, norm);
	S21:
	begin
		L_shlVar1Out = sum;
		L_shlNumShiftOut = norm;
		if(L_shlDone == 0)
			nextstate = S21;
		else if(L_shlDone == 1)
		begin
			nextsum = L_shlIn;
			sumLD = 1;
			nextstate = S22;
		end		
	end//S21
	
	//L_Extract(sum, &r_h[i], &r_l[i]);
	S22:
	begin
		L_shrVar1Out = sum;
		L_shrNumShiftOut = 32'd1;
		nexttemp = L_shrIn;
		tempLD = 1;
		nextstate = S23;
	end//S22
	
	//L_Extract(sum, &r_h[i], &r_l[i]);
	S23:
	begin
		L_msuOutA = sum[31:16];
		L_msuOutB = 16'd16384;
		L_msuOutC = temp;
		memOut = {sum[31:16],L_msuIn[15:0]};
		writeEn = 1;
		writeRequested = {AUTOCORR_R[11:4],i[3:0]};
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;		
		nextstate = S16;
	end//S23	
	endcase
end //end always

endmodule