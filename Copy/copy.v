`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:03:45 02/07/2011 
// Module Name:    copy 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "copy", which simply 
//						 copies two arrays in memory
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module copy(clk,reset,start,xAddr,yAddr,L,memIn,addIn,L_addIn,
				addOutA,addOutB,L_addOutA,L_addOutB,memWriteAddr,memReadAddr,memWriteEn,memOut,done);
//inputs				
input clk,reset,start;
input [10:0] xAddr,yAddr;
input [15:0] L;
input [31:0] memIn;
input [15:0] addIn;
input [31:0] L_addIn;

//outputs
output reg [15:0] addOutA,addOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [10:0] memWriteAddr,memReadAddr;
output reg memWriteEn;
output reg [31:0] memOut;
output reg done;

//reg declaration
reg [2:0] state,nextstate;
reg [15:0] count,nextcount;
reg countLD,countReset;
reg [10:0] tempAddr,nexttempAddr;
reg tempAddrLD, tempAddrReset;

//state flip flop
always@(posedge clk)
begin
	if(reset)
		state <= INIT;
	else
		state <= nextstate;
end

//count flip flop
always @(posedge clk)
begin
	if(reset)
		count <= 0;
	else if(countReset)
		count <= 0;
	else if(countLD)
		count <= nextcount;
end

//state parameters				
parameter INIT = 3'd0;
parameter COUNT_LOOP = 3'd1;
parameter COPY_STATE = 3'd2;

always @(*)
begin

	nextstate = state;
	nextcount = count;
	nexttempAddr = tempAddr;
	countLD = 0;
	countReset = 0;
	done = 0;
	addOutA = 0;
	addOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	memWriteAddr = 0;
	memReadAddr = 0;
	memWriteEn = 0;
	memOut = 0;
	
	case(state)
		INIT:
		begin
			if(start == 0)
			begin
				nextstate = INIT;
				countReset = 1;
			end
			else if(start == 1)				
				nextstate = COUNT_LOOP;
		end//INIT
		
		COUNT_LOOP:
		begin
			if(count >= L)
			begin
				nextstate = INIT;
				done = 1;
			end
			else if(count < L)
			begin				
				addOutA = {5'd0,xAddr[10:0]};
				addOutB = count;
				memReadAddr = addIn[10:0];
				nextstate = COPY_STATE;
			end
		end//COUNT_LOOP
		
		COPY_STATE:
		begin
			memOut = memIn;
			L_addOutA = {21'd0,yAddr[10:0]};
			L_addOutB = {16'd0,count[15:0]};			
			memWriteAddr = L_addIn[10:0];
			memWriteEn = 1;
			addOutA = count;
			addOutB = 16'd1;
			nextcount = addIn;
			countLD = 1;
			nextstate = COUNT_LOOP;
		end//COPY_STATE
	endcase
end//always

endmodule
