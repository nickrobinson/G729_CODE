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
module g729_hpfilter(mclk, reset,xn, ready, yn, done);

input mclk,reset,ready;
input [15:0] xn;
wire ld1,ld2,ld3,ld4,ld5,ld6,ld7;
wire mux0_sel,mux3_sel,mux4_sel;
wire [2:0] mux1_sel, mux2_sel;
output [15:0] yn;
output done;

preProcPipe preprocpipe(.mclk(mclk), .reset(reset), .xn(xn), .yn(yn), .ld1(ld1), .ld2(ld2), .ld3(ld3), .ld4(ld4),
.ld5(ld5), .ld6(ld6), .ld7(ld7), .mux0_sel(mux0_sel), .mux1_sel(mux1_sel), .mux2_sel(mux2_sel), 
.mux3_sel(mux3_sel), .mux4_sel(mux4_sel));

preProcFSM preprocfsm(.mclk(mclk), .reset(reset), .ready(ready), .done(done), .ld1(ld1), .ld2(ld2), .ld3(ld3),
.ld4(ld4), .ld5(ld5), .ld6(ld6), .ld7(ld7), .mux0_sel(mux0_sel), .mux1_sel(mux1_sel), .mux2_sel(mux2_sel),
.mux3_sel(mux3_sel), .mux4_sel(mux4_sel));

endmodule
