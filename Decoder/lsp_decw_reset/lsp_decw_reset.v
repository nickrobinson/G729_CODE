`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:34:16 10/08/2011 
// Design Name: 
// Module Name:    lsp_decw_reset 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: memReadAddr and memIN comes from constant memory.  memWriteAddr, memOut,
//							and memWriteEn comes from scratch memory.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_decw_reset(clk, reset, start, addIn, L_addIn, memIn, add_a, add_b, 
    L_add_a, L_add_b, memReadAddr, memWriteAddr, memOut, memWriteEn, done);

`include "paramList.v"
`include "constants_param_list.v"

//inputs
input clk,reset,start;
input [15:0] addIn;
input [31:0] L_addIn;
input [31:0] memIn;

//outputs
output reg [15:0] add_a,add_b;
output reg [31:0] L_add_a,L_add_b;
output reg [11:0] memReadAddr;
output reg [11:0] memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg done;

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

reg [15:0] i, nexti;
reg [3:0] state, nextstate;
reg nextdone;

parameter M = 16'd10;
parameter MA_NP = 16'd4;

copy copier(
				.clk(clk),
				.reset(reset),
				.start(copyStart),
				.xAddr(xAddr),
				.yAddr(yAddr),
				.L(M),
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
				
parameter INIT = 'd0;
parameter S1	= 'd1;
parameter S2	= 'd2;
parameter S3	= 'd3;
parameter S4	= 'd4;

always @(posedge clk)
	begin
		if(reset)
			state <= INIT;
		else
			state <= nextstate;
	end

//Done signal
always @(posedge clk)
	begin
		if(reset)
			done <= 0;
		else
			done <= nextdone;
	end
		
//counter
always @(posedge clk)
	begin
		if(reset)
			i <= 0;
		else
			i <= nexti;
	end


always @(*)
	begin
	nextstate = state;
	nexti = i;
	nextdone = 0;
	add_a = 0;
	add_b = 0;
	L_add_a = 0;
	L_add_b = 0;
	copyStart = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	memWriteEn = 0;
	xAddr = 0;
	yAddr = 0;
	
	case(state)
		INIT:
		begin
			if(start == 1)
				nextstate = S1;
			else
				nextstate = INIT;
		end
		S1:
		begin
			//for(i=0; i<MA_NP; i++)
			//Copy( &freq_prev_reset[0], &freq_prev[i][0], M );
			if(i >= MA_NP)
			begin
				nexti = 'd0;
				nextstate = S3;
			end
			else
			begin
				xAddr = FREQ_PREV_RESET;
				yAddr = {FREQ_PREV[11:6],i[1:0],4'd0};		
				add_a = copyAddOutA;
				add_b = copyAddOutB;
				L_add_a = copyL_addOutA;
				L_add_b = copyL_addOutB;
				memWriteAddr = copyMemWriteAddr;
				memReadAddr = copyMemReadAddr;
				memWriteEn = copyMemWriteEn;
				memOut = copyMemOut;
				copyStart = 1;
				if(copyDone == 1)
					nextstate = S2;
				else if(copyDone == 0)
					nextstate = S1;
			end
		end
		S2:
		begin
			//increment for loop
			add_a = i;
			add_b = 'd1;
			nexti = addIn;
			nextstate = S1;		
		end
		S3:
		begin
			//prev_ma = 0;
			memOut = 16'd0;		
			memWriteAddr = PREV_MA;
			memWriteEn = 1;
			nextstate = S4;
		end
		S4:
		begin
			//Copy( freq_prev_reset, prev_lsp, M);
			xAddr = FREQ_PREV_RESET;
			yAddr = PREV_LSP;		
			add_a = copyAddOutA;
			add_b = copyAddOutB;
			L_add_a = copyL_addOutA;
			L_add_b = copyL_addOutB;
			memWriteAddr = copyMemWriteAddr;
			memReadAddr = copyMemReadAddr;
			memWriteEn = copyMemWriteEn;
			memOut = copyMemOut;
			copyStart = 1;
			if(copyDone == 1)
			begin
				nextdone = 1;
				nextstate = INIT;
			end
			else if(copyDone == 0)
				nextstate = S4;
		end
		endcase
	end //always end


endmodule
