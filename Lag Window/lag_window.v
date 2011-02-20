`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:08:31 10/12/2010 
// Module Name:    lag_window 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to compute the lag window multiplication and return the r'(k) coefficients
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lag_window(clk,reset,start,rPrimeIn,L_multIn,multIn,L_macIn,L_msuIn,addIn,L_shrIn,rPrimeWrite,
						rPrimeRequested,rPrimeReadAddr,L_multOutA,L_multOutB,multOutA,multOutB,L_macOutA,
						L_macOutB,L_macOutC,L_msuOutA,L_msuOutB,L_msuOutC,rPrimeOut,addOutA, addOutB,
						L_shrOutVar1,L_shrOutNumShift,done);
`include "paramList.v"
//inputs 
input clk, reset,start;
input [31:0] rPrimeIn;
input [31:0] L_multIn;
input [15:0] multIn;
input [31:0] L_macIn;
input [31:0] L_msuIn;
input [15:0] addIn;
input [31:0] L_shrIn;

//outputs
output reg rPrimeWrite;
output reg [10:0] rPrimeReadAddr; 
output reg [10:0] rPrimeRequested;
output reg [15:0] L_multOutA,L_multOutB;
output reg [15:0] multOutA,multOutB;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [31:0] rPrimeOut;
output reg [15:0] addOutA, addOutB;
output reg [31:0] L_shrOutVar1;
output reg [15:0] L_shrOutNumShift;
output reg done;

//variable wires

wire [15:0] rHigh;
wire [15:0] rLow;

reg [15:0] rPrimeHigh;
reg [15:0] rPrimeLow;
reg [15:0] lagHigh;
reg [15:0] lagLow;

reg countLd,countReset;
reg [3:0] count,nextcount;
reg [3:0] state,nextstate;
reg productLd,productReset;
reg [31:0] product,nextproduct;
reg [31:0] temp,nexttemp;
reg templd,tempReset;

assign rHigh = rPrimeIn [31:16];
assign rLow = rPrimeIn [15:0];

//state parameters
parameter STATE_INIT = 4'd0;
parameter STATE_FIRST_R1 = 4'd1;
parameter STATE_FIRST_R2 = 4'd2;
parameter STATE_COUNT_LOOP = 4'd3;
parameter STATE_L_MULT = 4'd4;
parameter STATE_L_MAC1 = 4'd5;
parameter STATE_L_MAC2 = 4'd6;
parameter STATE_DONE = 4'd7;
parameter M = 10;

//state, count, and product flops
always @(posedge clk)
begin
	if(reset)
		state <= 0;
	else
		state <= nextstate;	
end	

always @(posedge clk)
begin
	if(reset)
		count <= 1;
	else if(countReset)
		count <= 1;
	else if(countLd)
		count <= nextcount;
end

always @(posedge clk)
begin
	if(reset)
		product <= 0;
	else if(productReset)
		product <= 0;
	else if(productLd)
		product <= nextproduct;
end

always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(templd)
		temp <= nexttemp;
end


always @(*)
begin

	nextstate = state;
	nextcount = count;
	nextproduct = product;
	nexttemp = temp;
	countLd = 0;
	productLd = 0;
	done = 0;
	rPrimeReadAddr = 0;
	rPrimeRequested = 0;
	rPrimeWrite = 0;
	countReset = 0;
	productReset = 0;
	rPrimeHigh = 0;
	rPrimeLow = 0;
   L_multOutA = 0;
	L_multOutB = 0;
	multOutA = 0;
	multOutB = 0;
   L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
   L_msuOutA = 0;
	L_msuOutB = 0;
   L_msuOutC = 0;
	templd = 0;
	tempReset = 0;
   rPrimeOut = 0;
   addOutA = 0; 
	addOutB = 0;
   L_shrOutVar1 = 0;
	L_shrOutNumShift = 0;

	case(state)
	
		STATE_INIT:
		begin			
			countReset = 1;
			productReset = 1;
			tempReset = 1;			
			if(start == 0)
				nextstate = STATE_INIT;
			else 
			begin
				nextstate = STATE_FIRST_R1;
				rPrimeReadAddr = {AUTOCORR_R[10:4],4'd0};
			end
		end
		
		STATE_FIRST_R1:
		begin
			rPrimeReadAddr = {AUTOCORR_R[10:4],4'd0};
			nexttemp = rPrimeIn;
			templd = 1;
			nextstate = STATE_FIRST_R2;		
		end//STATE_FIRST_R2:
		
		STATE_FIRST_R2:
		begin
			rPrimeWrite = 1;
			rPrimeRequested = {LAG_WINDOW_R_PRIME[10:4],4'd0};
			rPrimeOut = temp;
			nextstate = STATE_COUNT_LOOP;
		end//STATE_FIRST_R2:
			
		STATE_COUNT_LOOP:
		begin	
			
			if(count > M)
			begin
				nextstate = STATE_INIT;
				done = 1;
			end
			else if(count <= M)
			begin
				rPrimeReadAddr = {AUTOCORR_R[10:4],count};
				nextstate = STATE_L_MULT;	
			end			

		end //end STATE_COUNT_LOOP
		
		STATE_L_MULT:
		begin
			rPrimeReadAddr = {AUTOCORR_R[10:4],count};
			L_multOutA = rHigh;
			L_multOutB = lagHigh;
			nextproduct = L_multIn;
			productLd = 1;
			nextstate = STATE_L_MAC1;
		end// end STATE_L_MULT
		
		STATE_L_MAC1:
		begin
			rPrimeReadAddr = {AUTOCORR_R[10:4],count};
			multOutA = rHigh;
			multOutB = lagLow;
			L_macOutA = multIn;
			L_macOutB = 16'd1;
			L_macOutC = product;
			nextproduct = L_macIn;
			productLd = 1;
			nextstate = STATE_L_MAC2;
		end//STATE_L_MAC1
		
		STATE_L_MAC2:
		begin
			rPrimeReadAddr = {AUTOCORR_R[10:4],count};
			multOutA = rLow;
			multOutB = lagHigh;
			L_macOutA = multIn;
			L_macOutB = 16'd1;
			L_macOutC = product;
			nextproduct = L_macIn;
			productLd = 1;
			nextstate = STATE_DONE;
		end//STATE_L_MAC1:
		
		STATE_DONE:
		begin
			rPrimeWrite = 1;
			rPrimeRequested = {LAG_WINDOW_R_PRIME[10:4],count};
			//emulating the L_extract function
			rPrimeHigh = product[31:16];
			L_shrOutVar1 = {16'd0,product[15:0]};
			L_shrOutNumShift = 16'd1;
			L_msuOutA = product[31:16];
			L_msuOutB = 16'h8000;
			L_msuOutC = {16'd0,L_shrIn[15:0]};
			rPrimeLow = L_msuIn[15:0];	
			rPrimeOut = {rPrimeHigh, rPrimeLow};
			//end L_extract
			addOutA = count;
			addOutB = 16'd1;
			nextcount = addIn;
			countLd = 1;
			nextstate = STATE_COUNT_LOOP;
		end //STATE_DONE
	endcase
end	//end always

always @(*)	begin				 

	case(count)
	
	4'd1:	begin
	lagHigh = 15'd32728;
	lagLow = 15'd11904; 
	end	
	
	4'd2:	begin
	lagHigh = 15'd32619;
	lagLow = 15'd17280; 
	end	
	
	4'd3:	begin
	lagHigh = 15'd32438;
	lagLow = 15'd30720; 
	end	
	
	4'd4:	begin
	lagHigh = 15'd32187;
	lagLow = 15'd25856; 
	end	
	
	4'd5:	begin
	lagHigh = 15'd31867;
	lagLow = 15'd24192; 
	end	
	
	4'd6:	begin
	lagHigh = 15'd31480;
	lagLow = 15'd28992; 
	end	
	
	4'd7:	begin
	lagHigh = 15'd31029;
	lagLow = 15'd24384; 
	end	
	
	4'd8:	begin
	lagHigh = 15'd30517;
	lagLow = 15'd7360; 
	end	
	
	4'd9:	begin
	lagHigh = 15'd29946;
	lagLow = 15'd19520; 
	end	
	
	4'd10:	begin
	lagHigh = 15'd29321;
	lagLow = 15'd14784; 
	end	
	
	default: begin
	lagHigh = 15'd32728;
	lagLow = 15'd11904; 
	end	
	endcase

end//end always

endmodule
