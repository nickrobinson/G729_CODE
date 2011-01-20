`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:22:03 10/23/2010 
// Module Name:    gridPointsMux  
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a 61-way, 16bit memory to output all of the GRID_POINTS constants. See the "grid" 
//						array in the "tab_ld8k.c" file for reference
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module gridPointsMem(in,out);

input [5:0] in;
output reg [15:0] out;

always @(*) begin

case (in)

	'd0: out = 16'd32760;
	'd1: out = 16'd32723;
	'd2: out = 16'd32588;
	'd3: out = 16'd32364;
	'd4: out = 16'd32051;
	'd5: out = 16'd31651;
	'd6: out = 16'd31164;
	'd7: out = 16'd30591;
	'd8: out = 16'd29935;
	'd9: out = 16'd29196;
	'd10: out = 16'd28377;
	'd11: out = 16'd27481;
	'd12: out = 16'd26509;
	'd13: out = 16'd25465;
	'd14: out = 16'd24351;
	'd15: out = 16'd23170;
	'd16: out = 16'd21926;
	'd17: out = 16'd20621;
	'd18: out = 16'd19260;
	'd19: out = 16'd17846;  
	'd20: out = 16'd16384; 
	'd21: out = 16'd14876;
	'd22: out = 16'd13327;
	'd23: out = 16'd11743;
	'd24: out = 16'd10125;
	'd25: out = 16'd8480;
	'd26: out =	16'd6812;
	'd27: out = 16'd5126;
	'd28: out =	16'd3425;
	'd29: out = 16'd1714;
	'd30: out = 16'd0;	  
	'd31: out = ~(16'd1714)+1;
	'd32: out = ~(16'd3425)+1; 
	'd33: out = ~(16'd5126)+1;
	'd34: out =	~(16'd6812)+1;
	'd35: out =	~(16'd8480)+1;
	'd36: out = ~(16'd10125)+1;
	'd37: out =	~(16'd11743)+1;
	'd38: out = ~(16'd13327)+1;
	'd39: out =	~(16'd14876)+1;
	'd40: out =	~(16'd16384)+1;
	'd41: out = ~(16'd17846)+1;
	'd42: out =	~(16'd19260)+1;
	'd43: out =	~(16'd20621)+1;
	'd44: out = ~(16'd21926)+1;
	'd45: out =	~(16'd23170)+1;
	'd46: out =	~(16'd24351)+1;
	'd47: out =	~(16'd25465)+1;
	'd48: out =	~(16'd26509)+1;
	'd49: out =	~(16'd27481)+1;
	'd50: out =	~(16'd28377)+1;
	'd51: out = ~(16'd29196)+1;
	'd52: out =	~(16'd29935)+1;
	'd53: out =	~(16'd30591)+1;
	'd54: out =	~(16'd31164)+1;
	'd55: out =	~(16'd31651)+1;
	'd56: out =	~(16'd32051)+1;
	'd57: out = ~(16'd32364)+1;
	'd58: out = ~(16'd32588)+1;
	'd59: out =	~(16'd32723)+1;
	'd60: out = ~(16'd32760)+1;
endcase
end


endmodule
