`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    15:32:35 09/16/2010 
// Module Name:    LPC_Mem_Ctrl 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Vertex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Controller for the memory interface between the Pre-Processing
//						 block and the Auto-correlation block.  This controller is used
//						 to create a circular buffer that abstracts address referencing
//						 from the Pre-processing and Auto-correlation blocks.
//
// Dependencies: 	 AutoCorr_mem_1.xco
//
// Revision: 0.02 - Increased memory capacity and subsequent logic.  Added write
//						  management.
// Revision: 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LPC_Mem_Ctrl(clock, reset, In_Done, In_Sample, Out_Count, Out_Sample, frame_done);

//Inputs
input clock;
input reset;
input In_Done;
input [15:0] In_Sample;
input [7:0] Out_Count;

//Outputs
output [15:0] Out_Sample;
output reg frame_done;

//Internal Regs
reg [3:0] readState,nextreadState;
reg [3:0] writeState,nextwriteState;
reg [6:0] count,nextcount;
reg countLD;
reg [8:0] readAddr,writeAddr;
reg writeEn;
wire [15:0] doutb;


parameter INIT = 4'd0;
parameter S1 = 4'd1;
parameter S2 = 4'd2;
parameter S3 = 4'd3;
parameter S4 = 4'd4;
parameter S5 = 4'd5;
parameter S6 = 4'd6;
parameter S7 = 4'd7;

always @(posedge clock)
begin
	if(reset)
		readState <= INIT;
	else
		readState <= nextreadState;
end

always @(posedge clock)
begin
	if(reset)
		writeState <= INIT;
	else
		writeState <= nextwriteState;
end
	
always @(posedge clock)
begin
	if(reset)
		count <= 0;
	else if(countLD)
		count = nextcount;
end

//THE MEMORY
AutoCorr_mem_1 i_AutoCorr_mem_1(
											.addra(readAddr),
											.dina(16'd0),
											.wea(1'd0),
											.clka(clock),
											.douta(Out_Sample),
											.addrb(writeAddr), 
											.dinb(In_Sample), 
											.web(writeEn), 
											.clkb(clock), 
											.doutb(doutb)
											);

//writing always block
always @(*)
begin
	writeAddr = 0;
	writeEn = 0;
	nextwriteState = writeState;
	nextcount = count;
	countLD = 0;
	frame_done = 0;
	case(writeState)
		INIT:
		begin		
			if(In_Done)
			begin
				if(count == 79)
				begin
					writeAddr = (count + 200)%320;
					writeEn = 1;
					nextcount = 0;
					countLD = 1;
					nextwriteState = S1;
					frame_done = 1;
				end
				
				else
				begin
					writeAddr = (count + 200)%320;
					writeEn = 1;
					nextcount = count + 1;
					countLD = 1;
					nextwriteState = INIT;
					if(count == 39)
						frame_done = 1;
				end				
			end
			else
				nextwriteState = INIT;
		end//INIT
		
		S1:
		begin
			if(In_Done)
			begin
				if(count == 79)
				begin
					writeAddr = (count + 280)%320;
					writeEn = 1;
					nextcount = 0;
					countLD = 1;
					nextwriteState = S2;
					frame_done = 1;
				end
				
				else
				begin
					writeAddr = (count + 280)%320;
					writeEn = 1;
					nextcount = count + 1;
					countLD = 1;
					nextwriteState = S1;
					if(count == 39)
						frame_done = 1;
				end				
			end
			else
				nextwriteState = S1;
		end//S1
		
		S2:
		begin
			if(In_Done)
			begin
				if(count == 79)
				begin
					writeAddr = (count + 40)%320;
					writeEn = 1;
					nextcount = 0;
					countLD = 1;
					nextwriteState = S3;
					frame_done = 1;
				end
				
				else
				begin
					writeAddr = (count + 40)%320;
					writeEn = 1;
					nextcount = count + 1;
					countLD = 1;
					nextwriteState = S2;
					if(count == 39)
						frame_done = 1;
				end				
			end
			else
				nextwriteState = S2;
		end//S2
		
		S3:
		begin
			if(In_Done)
			begin
				if(count == 79)
				begin
					writeAddr = (count + 120)%320;
					writeEn = 1;
					nextcount = 0;
					countLD = 1;
					nextwriteState = INIT;
					frame_done = 1;
				end
				
				else
				begin
					writeAddr = (count + 120)%320;
					writeEn = 1;
					nextcount = count + 1;
					countLD = 1;
					nextwriteState = S3;
					if(count == 39)
						frame_done = 1;
				end				
			end
			else
				nextwriteState = S3;
		end//S3		
	endcase	
end//always

//read address always block
always @(*)
begin

	nextreadState = readState;
	readAddr = 0;
	case(readState)
	
		INIT:
		begin
			readAddr = (Out_Count + 40)%320;
			if(Out_Count >= 239)			
				nextreadState = S1;
			else
				nextreadState = INIT;
		end//INIT
		
		S1:
		begin
			readAddr = (Out_Count + 40)%320;
			if(Out_Count == 0)
				nextreadState = S2;
			else
				nextreadState = S1;
		end//S1
		
		S2:
		begin
			readAddr = (Out_Count + 120)%320;
			if(Out_Count >= 239)			
				nextreadState = S3;
			else
				nextreadState = S2;
		end//S2
		
		S3:
		begin
			readAddr = (Out_Count + 120)%320;
			if(Out_Count == 0)
				nextreadState = S4;
			else
				nextreadState = S3;
		end//S3
		
		S4:
		begin
			readAddr = (Out_Count + 200)%320;
			if(Out_Count >= 239)			
				nextreadState = S5;
			else
				nextreadState = S4;
		end//S4
			
		S5:
		begin
			readAddr = (Out_Count + 200)%320;
			if(Out_Count == 0)
				nextreadState = S6;
			else
				nextreadState = S5;
		end//S5
			
		S6:
		begin
			readAddr = (Out_Count + 280)%320;
			if(Out_Count >= 239)			
				nextreadState = S7;
			else
				nextreadState = S6;
		end//S3
		
		S7:
		begin
			readAddr = (Out_Count + 280)%320;
			if(Out_Count == 0)
				nextreadState = INIT;
			else
				nextreadState = S7;
		end//S7
	endcase
end//alwways
endmodule
