`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:50:39 04/12/2011 
// Module Name:    Enc_lag3_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Enc_lag3
// 
// Dependencies: 	 Scratch_Memory_Controller.v,add.v,sub.v
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Enc_lag3_pipe(clk,reset,start,Enc_lag3MuxSel,T0,T0_frac,pit_flag,testReadAddr,testWriteAddr,
							testMemOut,testMemWriteEn,done,index,memIn);

//Inputs
input clk,reset,start;
input Enc_lag3MuxSel;
input [15:0] T0,T0_frac,pit_flag;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testMemWriteEn;

//Outputs
output done;
output [15:0] index;
output [31:0] memIn;

//Internal Wires
wire [15:0] addIn;
wire [15:0] subIn;
wire [15:0] addOutA,addOutB;
wire [15:0] subOutA,subOutB;
wire [31:0] memOut;
wire [11:0] memReadAddr,memWriteAddr;
wire memWriteEn;

//Internal regs
reg [11:0] Enc_lag3MuxOut,Enc_lag3Mux1Out;
reg [31:0] Enc_lag3Mux2Out;
reg Enc_lag3Mux3Out;

//Instantiated modules	
Scratch_Memory_Controller testMem(
											 .addra(Enc_lag3Mux1Out),
											 .dina(Enc_lag3Mux2Out),
											 .wea(Enc_lag3Mux3Out),
											 .clk(clk),
											 .addrb(Enc_lag3MuxOut),
											 .doutb(memIn)
											 );
											 
sub Enc_lag3_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
					  );
					  
add Enc_lag3_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);	
											 
Enc_lag3 fsm(
				 .clk(clk),
				 .reset(reset),
				 .start(start),
				 .T0(T0),
				 .T0_frac(T0_frac),
				 .pit_flag(pit_flag),
				 .addIn(addIn),
				 .subIn(subIn),
				 .memIn(memIn),
				 .addOutA(addOutA),
				 .addOutB(addOutB),
				 .subOutA(subOutA),
				 .subOutB(subOutB),
				 .memReadAddr(memReadAddr),
				 .memWriteAddr(memWriteAddr),
				 .memWriteEn(memWriteEn),
				 .memOut(memOut),
				 .index(index),
				 .done(done)
				 );
				 
	//Memory muxes
	//Enc_lag3 read address mux
	always @(*)
	begin
		case	(Enc_lag3MuxSel)	
			'd0 :	Enc_lag3MuxOut = memReadAddr;
			'd1:	Enc_lag3MuxOut = testReadAddr;
		endcase
	end
	
	//Enc_lag3 write address mux
	always @(*)
	begin
		case	(Enc_lag3MuxSel)	
			'd0 :	Enc_lag3Mux1Out = memWriteAddr;
			'd1:	Enc_lag3Mux1Out = testWriteAddr;
		endcase
	end
	
	//Enc_lag3 write input mux
	always @(*)
	begin
		case	(Enc_lag3MuxSel)	
			'd0 :	Enc_lag3Mux2Out = memOut;
			'd1:	Enc_lag3Mux2Out = testMemOut;
		endcase
	end
	
	//Enc_lag3 write enable mux
	always @(*)
	begin
		case	(Enc_lag3MuxSel)	
			'd0 :	Enc_lag3Mux3Out = memWriteEn;
			'd1:	Enc_lag3Mux3Out = testMemWriteEn;
		endcase
	end
endmodule
