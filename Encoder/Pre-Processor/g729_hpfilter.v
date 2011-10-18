//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Dr. Tommy Morris, Zach Thornton
// 
// Create Date:    09:06:00 08/26/2010 
// Module Name:    g729_hpfilter.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a HDL implementation of the ITU G.729 pre-processing FIR filter.
// 					 The filter is has cutoff of 160 Hz and divides sample amplitude by 2.
// 					 This level instantiates the datapath (called pipe) and a fsm to control the 
// 					 datapath
//
// Dependencies: 	 reg_Q31.vm twoway_Q31mux.v,fiveway_constantmux.v, multQ31.v, addQ31.v

//
//////////////////////////////////////////////////////////////////////////////////
module g729_hpfilter(clk, reset,xn, ready, yn, done);

input clk,reset,ready;
input [15:0] xn;

output [15:0] yn;
output done;


preProcFSM preprocfsm(
							 .clk(clk),
							 .reset(reset),
							 .ready(ready),
							 .xn(xn),
							 .yn(yn),
							 .done(done)
							 );

endmodule
