`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:52:35 02/08/2011 
// Module Name:    Lsp_prev_update .v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Lsp_prev_update".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lsp_prev_update(clk,reset,start,addIn,subIn,L_addIn,memIn,lsp_eleAddr,freq_prevAddr,
							  addOutA,addOutB,subOutA,subOutB,L_addOutA,L_addOutB,memReadAddr,memWriteAddr,
							  memOut,memWriteEn,done);

//inputs
input clk,reset,start;
input [15:0] addIn;
input [15:0] subIn; 
input [31:0] L_addIn;
input [31:0] memIn;
input [11:0] lsp_eleAddr;
input [11:0] freq_prevAddr;

//outputs
output reg [15:0] addOutA,addOutB;
output reg [15:0] subOutA,subOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [11:0] memReadAddr;
output reg [11:0] memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg done;

//regs
reg [2:0] state,nextstate;
reg [2:0] k,nextk;
reg kLD,kReset;

//copy regs and wires
reg copyStart;
reg [11:0] xAddr,yAddr;
wire [15:0] copyAddOutA,copyAddOutB;
wire [31:0] copyL_addOutA,copyL_addOutB;
wire [11:0] copyMemWriteAddr;
wire [11:0] copyMemReadAddr;
wire copyMemWriteEn;
wire [31:0] copyMemOut;
wire copyDone;

//instantiated modules
copy copier(
				.clk(clk),
				.reset(reset),
				.start(copyStart),
				.xAddr(xAddr),
				.yAddr(yAddr),
				.L(16'd10),
				.memIn(memIn),
				.addIn(addIn),
				.L_addIn(L_addIn),
				.addOutA(copyAddOutA),
				.addOutB(copyAddOutB),
				.L_addOutA(copyL_addOutA),
				.L_addOutB(copyL_addOutB),
				.memWriteAddr(copyMemWriteAddr),
				.memReadAddr(copyMemReadAddr),
				.memWriteEn(copyMemWriteEn),
				.memOut(copyMemOut),
				.done(copyDone)
				);

//state params
parameter INIT = 3'd0;
parameter FOR_LOOP = 3'd1;
parameter COPY1 = 3'd2;
parameter COPY1_2 = 3'd3;
parameter COPY2 = 3'd4;

//state flipflop
always @(posedge clk)
begin
	if(reset)
		state <= 0;
	else
		state <= nextstate;
end

//k flipflop
always @(posedge clk)
begin
	if(reset)
		k <= 3'd3;
	else if (kReset)
		k <= 3'd3;
	else if(kLD)
		k <= nextk;
end		

always @(*)
begin
	nextstate = state;
	nextk = k;
	kLD = 0;
	kReset = 0;
	copyStart = 0;
	addOutA = 0;
	addOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	memWriteEn = 0;
	done = 0;
	subOutA = 0;
	subOutB = 0;
	xAddr = 0;
	yAddr = 0;
	
	case(state)
	
	INIT:
	begin
		if(start == 0)
			nextstate = INIT;
		else if(start == 1)
		begin
			kReset = 1;
			nextstate = FOR_LOOP;
		end
	end//INIT
	
	//for ( k = MA_NP-1 ; k > 0 ; k-- )
	FOR_LOOP:
	begin
		if(k <= 0)
			nextstate = COPY2;
		else if(k > 0)
			nextstate = COPY1;
	end//FOR_LOOP1
	
	//Copy(freq_prev[k-1], freq_prev[k], M);
	COPY1:
	begin
			subOutA = k;
			subOutB = 1;
			xAddr = {freq_prevAddr[10:6],subIn[1:0],4'd0};
			yAddr = {freq_prevAddr[10:6],k[1:0],4'd0};		
			addOutA = copyAddOutA;
			addOutB = copyAddOutB;
			L_addOutA = copyL_addOutA;
			L_addOutB = copyL_addOutB;
			memWriteAddr = copyMemWriteAddr;
			memReadAddr = copyMemReadAddr;
			memWriteEn = copyMemWriteEn;
			memOut = copyMemOut;
			copyStart = 1;
			if(copyDone == 1)
				nextstate = COPY1_2;
			else if(copyDone == 0)
				nextstate = COPY1;
	end//COPY1
	
	COPY1_2:
	begin
		subOutA = k;
		subOutB = 1;
		nextk = subIn;
		kLD = 1;
		nextstate = FOR_LOOP;
	end//COPY1_2
	
	//Copy(lsp_ele, freq_prev[0], M);
	COPY2:
	begin
		xAddr = lsp_eleAddr;
		yAddr = {freq_prevAddr[10:6],6'd0};		
		addOutA = copyAddOutA;
		addOutB = copyAddOutB;
		L_addOutA = copyL_addOutA;
		L_addOutB = copyL_addOutB;
		memWriteAddr = copyMemWriteAddr;
		memReadAddr = copyMemReadAddr;
		memWriteEn = copyMemWriteEn;
		memOut = copyMemOut;
		copyStart = 1;
		if(copyDone == 1)
		begin
			nextstate = INIT;
			done = 1;
		end
		else if(copyDone == 0)
			nextstate = COPY2;
	end//COPY2
	
	endcase
end//always

endmodule
