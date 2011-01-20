`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer:  Tommy Morris
// 
// Create Date:    11:00:50 09/11/2010
// Module Name:    shl.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This function implements the "shl" function from the ITU G729 C reference model. 
// Dependencies: 	none 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module shl(var1,var2,overflow,result);

// var1 = number to be shifted
// var2 = number of shifts 
input [15:0] var1, var2;

// result = result after shifting
output reg [15:0] result;
output reg [15:0] overflow;

wire [15:0] negvar2 = ~(var2) + 16'd1;
wire [15:0] shrresult;

shr i_shr(.var1(var1), .var2(negvar2), .result(shrresult)); 

always @(*)
begin
  overflow = 0;
  if (var2[15] == 1'b1) // (var2 < 0)
    result = shrresult;
  else 
  begin
		if((var2 > 16'd15) && (var1 != 0))
		begin
			overflow = 1;
			if(var1[15] == 0)
				result = 16'h7fff;
			else
				result = 16'h8000;
		end
		
		else
			result = var1 << var2;
  end
  
end//always

endmodule
