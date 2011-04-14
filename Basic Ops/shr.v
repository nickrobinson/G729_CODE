`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer:  Tommy Morris
// 
// Create Date:    11:00:50 09/11/2010
// Module Name:    shr.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This function implements the "shr" function from the ITU G729 C reference model. 
// Dependencies: 	none 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module shr(var1,var2,overflow,result);

// var1 = number to be shifted
// var2 = number of shifts 
input signed [15:0] var1, var2;

// result = result after shifting
output reg signed [15:0] result;
output reg overflow;

wire var1gt0 = ~(var1[15]);
wire [15:0] negvar2 = ~(var2) + 16'd1; 

reg [31:0] resultat;

always @(*)
  begin
    overflow = 0;
	 
	 /* If var2 is negative, do an shl */
    if (var2[15] == 1) // (var2 < 0)
	 begin
		if(var1[15] == 1) begin
			resultat = {16'd1,var1} << (negvar2 + 'd1);
		end
		else begin
			resultat = {16'd0,var1} << (negvar2 + 'd1);
		end
      if((negvar2 > 16'd15) && (var1 != 0) || resultat[31:16] != 16'hffff || resultat[31:16] != 16'd0)
		begin
			overflow = 1;
			if(var1[15] == 0)
				result = 16'h7fff;
			else
				result = 16'h8000;
		end
		
		else
			result = var1 << negvar2;
	 end
	 
    else 
	 begin//else1
		 
		if (var2 >= 16'd15)//if 2
		begin
			overflow = 1;
			if(var1gt0)
				result = 16'h0;
			else if(~var1gt0)
				result = 16'hffff;			
		end//if2
		 
		else // else2
			result = var1 >>> var2;			
	 end//else 1
  end //end always

endmodule
