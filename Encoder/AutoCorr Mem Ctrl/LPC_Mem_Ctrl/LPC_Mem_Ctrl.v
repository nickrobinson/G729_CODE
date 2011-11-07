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
// Dependencies: 	 auto_corr_mem_1
//
// Revision: 0.02 - Increased memory capacity and subsequent logic.  Added write
//						  management.
// Revision: 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LPC_Mem_Ctrl(clock, reset, In_Done, In_Sample, Out_Count, Out_Sample, memWriteAddr, memIn, memWriteEn, mathMuxSel, frame_done);
   input clock;
	input reset;
	input In_Done;
   input [15:0] In_Sample;
   input [7:0] Out_Count;
   output [31:0] Out_Sample;
	output frame_done;
	input [7:0] memWriteAddr;
	input [31:0] memIn;
	input memWriteEn;
	input [5:0] mathMuxSel;

	reg [8:0] nextaddra;
	reg [7:0] addra,addrb;	
	reg [8:0] nextaddrb;
	reg [31:0] dina;
	reg wea;
	reg web;
	reg weaflag,webflag;
	reg frame_done;
	reg framedoneflag;
	reg [5:0] frame_count;
	reg [5:0] nextframe_count;
	reg [31:0] dinb;
	wire [31:0] doutb;
	 
	parameter rstate1 = 2'd0;
	parameter rstate2 = 2'd1;
	parameter rstate3 = 2'd2;
	parameter rstate4 = 2'd3;
	
	parameter start1 = 9'd40;
	parameter start2 = 9'd120;
	parameter start3 = 9'd200;
	parameter start4 = 9'd280;
	
	reg [1:0] rcurrentState;
	reg [1:0] rnextState;
	 
//	Speech_Memory_Controller Speech_Mem (.addra(Out_Count),.dina(16'd0),.wea(1'd0),.clka(clock),
//		.douta(Out_Sample), .addrb(addrb), .dinb(dinb), .web(webflag), .clkb(clock), .doutb(doutb));

	Speech_Memory_Controller Speech_Mem (.addra(addra),.dina(dina),.wea(weaflag),.clka(clock),
		.clkb(clock), .addrb(Out_Count), .doutb(Out_Sample));
		
	always @ (*)
	begin
		if (mathMuxSel == 'd48)
		begin
			addra = memWriteAddr;
			weaflag = memWriteEn;
		end
		else
		begin
			addra = addrb;
			weaflag = webflag;
		end
	end	

	always @ (*)
	begin
		if (mathMuxSel == 'd48)
			dina = memIn;
		else
		begin
			if (In_Sample[15] == 1)
				dina = {16'hffff, In_Sample};
			else
				dina = {16'd0, In_Sample};
		end
	end
	
//	always@(posedge clock)begin
//		if(reset) begin
//			rcurrentState <= rstate1;
//		end
//		else begin
//			rcurrentState <= rnextState;
//		end
//	end
//	
//	always@(posedge clock)begin
//		if(reset) begin
//			addra <= start1;
//		end
//		else begin
//			addra <= nextaddra;
//		end
//	end
//	
//	always@(*)begin
//	
//		rnextState = rcurrentState; 
//		case(rcurrentState)
//		
//			rstate1: begin
//				nextaddra = start1 + Out_Count;
//				if(addra == 279) begin
//					rnextState = rstate2;
//					nextaddra = start2;
//				end
//				else
//					rnextState = rstate1;
//			end
//			
//			rstate2: begin
//				if(Out_Count >= 200)
//					nextaddra = Out_Count - 200;
//				else if(Out_Count < 200)
//					nextaddra = start2 + Out_Count;
//				if(addra == 39) begin
//					rnextState = rstate3;
//					nextaddra = start3;
//				end
//				else
//					rnextState = rstate2;
//			end
//			
//			rstate3: begin
//				if(Out_Count < 120)
//					nextaddra = start3 + Out_Count;
//				else
//					nextaddra = Out_Count - 120;
//				if(addra == 119) begin
//					rnextState = rstate4;
//					nextaddra = start4;
//				end
//				else
//					rnextState = rstate3;
//			end
//			
//			rstate4: begin
//				if(Out_Count < 40)
//					nextaddra = start4 + Out_Count;
//				else
//					nextaddra = Out_Count - 40;
//				if(addra == 199) begin
//					rnextState = rstate1;
//					nextaddra = start1;
//				end
//				else
//					rnextState = rstate4;
//			end
//		endcase
//	end
	
	always@(posedge clock)begin
		if(reset) begin
			addrb <= 160;
		end
		else begin
			addrb <= nextaddrb;
		end
	end
	
	always@(posedge clock)begin
		if(reset) begin
			frame_count <= 0;
		end
		else begin
			frame_count <= nextframe_count;
		end
	end
	
//	always@(posedge clock) begin
//		if(reset) begin
//			web = 0;
//		end
//		else begin
//			if(webflag)
//				web = 1;
//			else
//				web = 0;
//		end
//	end
	
	always@(posedge clock) begin
		if(reset) begin
			frame_done = 0;
		end
		else begin
			if(framedoneflag)
				frame_done = 1;
			else
				frame_done = 0;
		end
	end

	always@(*)begin
		nextaddrb = addrb;
		nextframe_count = frame_count;
		//added code
		framedoneflag = 0;
		webflag = 0;
		if(In_Done) begin
			if(addrb == 239) begin
				nextaddrb = 160;
				webflag = 1;
				nextframe_count = frame_count + 1;
			end
			else begin
				nextaddrb = addrb + 8'd1;
				webflag = 1;
				nextframe_count = frame_count + 1;
			end
			if(nextframe_count == 6'd40) begin
				nextframe_count = 6'd0;
				framedoneflag = 1;
			end
		end
	end
	
//	always@(negedge In_Done)begin
//		framedoneflag = 0;
//		webflag = 0;
//	end

	
	
endmodule
