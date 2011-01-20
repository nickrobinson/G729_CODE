`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:37:12 08/25/2010
// Module Name:    preProcFSM.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This module implements the Finite State Machine that controls the data loading of the registers, 
//						 the muxes, and indicates when the sampling is complete. 
//
// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////
module preProcFSM(mclk,reset,ready,done,ld1,ld2,ld3,ld4,ld5,ld6,ld7,mux0_sel,mux1_sel,mux2_sel,mux3_sel,mux4_sel);

	input reset,mclk,ready;
	output ld1,ld2,ld3,ld4,ld5,ld6,ld7,mux0_sel,mux3_sel,mux4_sel,done;
	output [2:0] mux1_sel,mux2_sel;	

  parameter INIT = 0;
  parameter S1 = 1;
  parameter S2 = 2;
  parameter S3 = 3;
  parameter S4 = 4;
  parameter S5 = 5;
  parameter S6 = 6;

  
  reg [2:0]  state, nextstate;
  reg ld1,ld2,ld3,ld4,ld5,ld6,ld7,mux0_sel,mux3_sel,mux4_sel,done;
  reg [2:0] mux1_sel,mux2_sel;
  
  always @(posedge mclk) 
 begin
	if (reset)
	 state <= INIT;
	else 
	 state <= nextstate;
 end

  always @(*) begin	
  ld1 = 0;
  ld2 = 0;
  ld3 = 0;
  ld4 = 0;
  ld5 = 0;
  ld6 = 0;
  ld7 = 0;
  mux0_sel= 0;
  mux1_sel = 0;
  mux2_sel = 0;
  mux3_sel = 0;
  mux4_sel = 0;
  done = 0;
  nextstate = state;
  
	case(state)
	INIT: begin
	nextstate = INIT;
	
	if(ready) begin
	nextstate = S1;
	mux0_sel = 1;	//R7 = multiplier output = N2
	//N3 = x[n-1] * -3798
	mux1_sel = 0;	//mux 1 = x[n-1] = R1
	mux2_sel = 0;	//mux 2 = -3798
	ld5 = 1;		// R5 = x[n] 
	ld6 = 1;		//R6 = multipler out = N3 
	end//end if
	
	end //INIT
	
	S1: begin
	nextstate = S2;
	mux0_sel = 1;	//mux 0 = multiplier output = N2
	// N2 = 1899 * x[n]
	mux1_sel = 1;	// mux 1 = x[n] = R5
	mux2_sel = 1;	// mux 2 = 1899
	ld7 = 1;		//R7 = mux 0 = N2 
	end //end S1
	
	S2: begin
	nextstate = S3;
	mux0_sel = 0;	//mux 0 = adder output = N4 = N2 +N3
	//N8 = x[n-2] * 1899
	mux1_sel = 2;	//mux 1 = x[n-2] = R2
	mux2_sel = 2;	//mux 2 = 1899
	ld6 = 1;		//R6 = N8
	ld7 = 1;		//R7 = R4
	end//end S2
	
	S3: begin
	nextstate = S4;
	//N9 = y[n-1] * 7807
	mux1_sel = 3;	//mux 1 = y[n-1] = R3
	mux2_sel = 3;	//mux 2 = y[n-2] = R4
	ld6 = 1;		//R6 = N9
	ld7 = 1;		//R7 = N5 = N4 + N8
	end //end S3
	
	S4: begin
	nextstate = S5;
	//N10 = y[n-2] * -3733
	mux1_sel = 4;	//mux 1 = y[n-2] = R4
	mux2_sel = 4;	//mux 2 = -3733
	ld6 = 1;		//R6 = N10
	ld7 = 1;		//R7 = N6 = N5+N9	
	end //end S4
	
	S5: begin
	nextstate = S6;
	//N10 = y[n-2] * -3733
	mux1_sel = 4;	//mux 1 = y[n-2] = R4
	mux2_sel = 4;	//mux 2 = -3733
	ld3 = 1;		//update R3 from the old y[n] to the new y[n-1]
	ld1 = 1;		//update R1 from the old x[n] to the new x[n-1]
	ld2 = 1;	//update R2 from the old x[n-1] to the new x[n-2]
	ld4 = 1;	//update R4 from the old y[n-1] to the new y[n-2]
	end //end S5
	
	S6: begin
	nextstate = INIT;
	done = 1;		//indcate the results are ready
	//N11 = N7 + 0x0000_8000 for rounding the final y[n]
	mux3_sel = 1;	//mux 3 = N7 = N6 + N10 
	mux4_sel = 1;	//mux 4 = 0x0000_8000
	end //S6
	endcase
	
	end //end always block
endmodule
