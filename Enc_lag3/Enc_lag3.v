`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    11:14:08 04/12/2011
// Module Name:    Enc_lag3.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Enc_lag3".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Enc_lag3(clk,reset,start,T0,T0_frac,pit_flag,addIn,subIn,memIn,addOutA,addOutB,
					 subOutA,subOutB,memReadAddr,memWriteAddr,memWriteEn,
					 memOut,index,done);
`include "paramList.v"

//Inputs
input clk,reset,start;
input [15:0] T0,T0_frac,pit_flag;
input [15:0] addIn;
input [15:0] subIn;
input [31:0] memIn;

//Outputs
output reg [15:0] addOutA,addOutB;
output reg [15:0] subOutA,subOutB;
output reg [11:0] memReadAddr,memWriteAddr;
output reg memWriteEn;
output reg [31:0] memOut;
output [15:0] index;
output reg done;

//Internal regs
reg [4:0] state,nextstate;
reg [15:0] index,nextindex;
reg indexLD,indexReset;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [31:0] temp,nexttemp;
reg tempLD,tempReset;
reg [15:0] T0Reg,T0_fracReg,pit_flagReg;
reg T0RegLD,T0_fracRegLD,pit_flagRegLD;

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

//Flip flops
always @(posedge clk)
begin
	if(reset)
		state <= INIT;
	else
		state <= nextstate;
end

always @(posedge clk)
begin
	if(reset)
		index <= 0;
	else if(indexReset)
		index <= 0;
	else if(indexLD)
		index <= nextindex;
end

always @(posedge clk)
begin
	if(reset)
		i <= 0;
	else if(iReset)
		i <= 0;
	else if(iLD)
		i <= nexti;
end

always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <= nexttemp;
end

always @(posedge clk)
begin
	if(reset)
		T0Reg <= 0;
	else if(T0RegLD)
		T0Reg <= T0;
end

always @(posedge clk)
begin
	if(reset)
		T0_fracReg <= 0;
	else if(T0_fracRegLD)
		T0_fracReg <= T0_frac;
end

always @(posedge clk)
begin
	if(reset)
		pit_flagReg <= 0;
	else if(pit_flagRegLD)
		pit_flagReg <= pit_flag;
end


//State machine always block
always @(*)
begin
	addOutA = 0;
	addOutB = 0;
	subOutA = 0;
	subOutB = 0;	
	memReadAddr = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	memOut = 0;
	done = 0;
	nextstate = state;
	nextindex = index;
	nexttemp = temp;
	nexti = i;
	indexReset = 0;
	iReset = 0;
	tempReset = 0;
	indexLD = 0;
	iLD = 0;
	tempLD = 0;
	T0RegLD = 0;
	T0_fracRegLD = 0;
	pit_flagRegLD = 0;
	
	case(state)
	
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				indexReset = 1;
				iReset = 1;
				tempReset = 1;
				T0RegLD = 1;
				T0_fracRegLD = 1;
				pit_flagRegLD = 1;
				nextstate = S1;
			end
		end//INIT
		
		//if (pit_flag == 0)
		S1:
		begin
			if(pit_flagReg == 0)
				nextstate = S2;
			else
			begin
				memReadAddr = T0_MIN;
				nextstate = S14;
			end
		end//S1
		
		//if (sub(T0, 85) <= 0)
		S2:
		begin
			subOutA = T0Reg;
			subOutB = 16'd85;
			if(subIn[15] == 1 || subIn == 0)
				nextstate = S3;
			else
				nextstate = S7;		
		end//S2
		
		//add(T0, T0)
		S3:
		begin
			addOutA = T0Reg;
			addOutB = T0Reg;
			nexttemp = addIn;
			tempLD = 1;
			nextstate = S4;
		end//S3
		
		//i = add(add(T0, T0), T0);
		S4:
		begin
			addOutA = temp;
			addOutB = T0;
			nexti = addIn;
			iLD = 1;
			nextstate = S5;
		end//S4
		
		//sub(i, 58)
		S5:
		begin
			subOutA = i;
			subOutB = 16'd58;
			nexttemp = subIn;
			tempLD = 1;
			nextstate = S6;
		end//S5
		
		//index = add(sub(i, 58), T0_frac);
		S6:
		begin
			addOutA = temp;
			addOutB = T0_fracReg;
			nextindex = addIn;
			indexLD = 1;
			nextstate = S8;
		end//S6
		
		/* else {
			 index = add(T0, 112);} */
		S7:
		begin
			addOutA = T0Reg;
			addOutB = 16'd112;
			nextindex = addIn;
			indexLD = 1;
			nextstate = S8;
		end//S7
		
		//*T0_min = sub(T0, 5);
		S8:
		begin
			subOutA = T0Reg;
			subOutB = 16'd5;
			nexttemp = subIn;
			tempLD = 1;
			memOut = subIn;
			memWriteAddr = T0_MIN;
			memWriteEn = 1;
			nextstate = S9;
		end//S8
		
		/* if (sub(*T0_min, pit_min) < 0) 
			*T0_min = pit_min; */
		S9:
		begin
			subOutA = temp;
			subOutB = 16'd20;
			if(subIn[15] == 1)
			begin
				memOut = 32'd20;
				memWriteAddr = T0_MIN;
				memWriteEn = 1;
				nexttemp = 32'd20;
				tempLD = 1;
			end
			nextstate = S10;			
		end//S9
		
		//*T0_max = add(*T0_min, 9);
		S10:
		begin
			addOutA = temp;
			addOutB = 16'd9;
			memOut = addIn;
			memWriteAddr = T0_MAX;
			memWriteEn = 1;
			nexttemp = addIn;
			tempLD = 1;
			nextstate = S12;
		end//S10
		
		/* if (sub(*T0_max, pit_max) > 0)
			*T0_max = pit_max; */
		S11:
		begin
			subOutA = temp;
			subOutB = 16'd143;
			if(subIn[15] == 1)
			begin
				memOut = 16'd143;
				memWriteEn = 1;
				memWriteAddr = T0_MAX;
				nextstate = S12;
			end			
			else
			begin
				done = 1;
				nextstate = INIT;
			end
		end//S11		
		
		//*T0_min = sub(*T0_max, 9);
		S12:
		begin
			subOutA = temp;
			subOutB = 16'd9;
			memOut = subIn;
			memWriteAddr = T0_MIN;
			nextstate = S13;
		end//S12
		
		S13:
		begin
			done = 1;
			nextstate = INIT;
		end//S13
		
		/* else {
         i = sub(T0, *T0_min); */
		S14:
		begin
			subOutA = T0Reg;
			subOutB = memIn[15:0];
			nexti = subIn;
			iLD = 1;
			nextstate = S15;
		end//S14
		
		//add(i, i)
		S15:
		begin
			addOutA = i;
			addOutB = i;
			nexttemp = addIn;
			tempLD = 1;
			nextstate = S16;
		end//S15
		
		//i = add(add(i, i), i);
		S16:
		begin
			addOutA = temp;
			addOutB = i;
			nexti = addIn;
			iLD = 1;
			nextstate = S17;
		end//S16
		
		//add(i, 2)
		S17:
		begin
			addOutA = i;
			addOutB = 16'd2;
			nexttemp = addIn;
			tempLD = 1;
			nextstate = S18;
		end//S17
		
		//index = add(add(i, 2), T0_frac);
		S18:
		begin
			addOutA = temp;
			addOutB = T0_fracReg;
			nextindex = addIn;
			indexLD = 1;
			nextstate = S13;
		end//S18
	endcase
end//always

endmodule
