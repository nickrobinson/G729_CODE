`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:05:21 03/02/2011 
// Design Name: 
// Module Name:    Lag_max 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lag_max(clk, start, reset, done, signal, L_frame, lag_max, lag_min, cor_max, p_max, writeAddr, writeOut, writeEn, 
					readAddr, readIn, add_a, add_b, add_in, sub_a, sub_b, sub_in, L_mac_a, L_mac_b, L_mac_c, L_mac_in, 
					L_sub_a, L_sub_b, L_sub_in, L_msu_a, L_msu_b, L_msu_c, L_msu_in, L_shr_a, L_shr_b, L_shr_in, L_add_a, 
					L_add_b, L_add_in, L_mult_in, mult_in, L_mult_a, L_mult_b, mult_a, mult_b, norm_l_in, norm_l_done,
					L_shl_in, L_shl_done, shr_in, constantMemIn, constantMemAddr, norm_l_var1, norm_l_ready, L_shl_var1, 
					L_shl_numshift, L_shl_ready, shr_var1, shr_var2);

	input clk, start, reset;
	input [11:0] signal;
	input [15:0] L_frame, lag_max, lag_min;
	input [31:0] readIn;
	
	output reg done;
	output reg [11:0] writeAddr;
	output reg [31:0] writeOut;
	output reg writeEn;
	output reg [11:0] readAddr;
	output reg [15:0] cor_max;
	output reg [15:0] p_max;
	
	input [31:0] L_mac_in, L_sub_in, L_msu_in, L_shr_in, L_add_in;
	input [15:0] add_in, sub_in;
	output reg [15:0] L_mac_a, L_mac_b, add_a, add_b, sub_a, sub_b;
	output reg [15:0] L_msu_a, L_msu_b, L_shr_b;
	output reg [31:0] L_mac_c, L_msu_c, L_sub_a, L_sub_b, L_shr_a;
	output reg [31:0] L_add_a, L_add_b;

	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	parameter S4 = 4;
	parameter S5 = 5;
	parameter S6 = 6;
	parameter S7 = 7;
	parameter S8 = 8;
	parameter S9 = 9;
	parameter S10 = 10;
	parameter S11 = 11;
	parameter S12 = 12;

	reg [3:0] state, nextstate;
	reg [15:0] i, nexti, j, nextj;
	reg [15:0] p, next_p, p1, next_p1;
	reg [15:0] p_temp, next_p_temp;
	reg [15:0] next_p_max;
	reg [15:0] max_h, next_max_h, max_l, next_max_l;
	reg [15:0] ener_h, next_ener_h, ener_l, next_ener_l;
	reg [31:0] max, next_max;
	reg [31:0] t0, next_t0;
	reg [31:0] L_temp, next_L_temp;
	reg [15:0] next_cor_max;
	reg next_done;
	
	reg Mpy_32_start;
	wire Mpy_32_done;
	reg [31:0] Mpy_32_var1, Mpy_32_var2;
	input [31:0] L_mult_in;
	input [15:0] mult_in;
	output [15:0] L_mult_a, L_mult_b, mult_a, mult_b;
	wire [15:0] Mpy_32_L_mac_a, Mpy_32_L_mac_b;
   wire [31:0] Mpy_32_L_mac_c, Mpy_32_out;

	Mpy_32 i_Mpy_32(
	.clock(clk), 
	.reset(reset), 
	.start(Mpy_32_start), 
	.done(Mpy_32_done), 
	.var1(Mpy_32_var1), 
	.var2(Mpy_32_var2), 
	.out(Mpy_32_out), 
	.L_mult_outa(L_mult_a), 
	.L_mult_outb(L_mult_b),
	.L_mult_overflow(), 
	.L_mult_in(L_mult_in), 
	.L_mac_outa(Mpy_32_L_mac_a), 
	.L_mac_outb(Mpy_32_L_mac_b), 
	.L_mac_outc(Mpy_32_L_mac_c), 
	.L_mac_overflow(), 
	.L_mac_in(L_mac_in), 
	.mult_outa(mult_a), 
	.mult_outb(mult_b), 
	.mult_in(mult_in), 
	.mult_overflow());
	
	wire Inv_sqrt_done;
	reg Inv_sqrt_start;
	input [15:0] norm_l_in;
	input norm_l_done;
	input [31:0] L_shl_in;
	input L_shl_done;
	input [15:0] shr_in;
	input [31:0] constantMemIn;	
	wire [31:0] Inv_sqrt_out;
	output [31:0] norm_l_var1;
	output norm_l_ready;
	output [31:0] L_shl_var1; 
	output [15:0] L_shl_numshift;
	output L_shl_ready;
	wire [15:0] Inv_sqrt_sub_a, Inv_sqrt_sub_b;
	wire [31:0] Inv_sqrt_L_shr_var1;
	wire [15:0] Inv_sqrt_L_shr_numshift;
	output [15:0] shr_var1, shr_var2;
	wire [15:0] Inv_sqrt_add_a, Inv_sqrt_add_b;
	wire [15:0] Inv_sqrt_L_msu_a, Inv_sqrt_L_msu_b;
	wire [31:0] Inv_sqrt_L_msu_c;
	output [11:0] constantMemAddr;
	
	
	Inv_sqrt i_Inv_sqrt(
	.clk(clk),
	.start(Inv_sqrt_start),
	.reset(reset),
	.in(t0),
	.norm_lIn(norm_l_in),
	.norm_lDone(norm_l_done),
	.L_shlIn(L_shl_in),
	.L_shlDone(L_shl_done),
	.subIn(sub_in),
	.L_shrIn(L_shr_in),
	.shrIn(shr_in),
	.addIn(add_in),
	.L_msuIn(L_msu_in),
	.constantMemIn(constantMemIn),
	.norm_lVar1Out(norm_l_var1),
	.norm_lReady(norm_l_ready),
	.L_shlVar1Out(L_shl_var1),
	.L_shlNumShiftOut(L_shl_numshift),
	.L_shlReady(L_shl_ready),
	.subOutA(Inv_sqrt_sub_a),
	.subOutB(Inv_sqrt_sub_b),
	.L_shrVar1Out(Inv_sqrt_L_shr_var1),
	.L_shrNumShiftOut(Inv_sqrt_L_shr_numshift),
	.shrVar1Out(shr_var1),
	.shrVar2Out(shr_var2),
	.addOutA(Inv_sqrt_add_a),
	.addOutB(Inv_sqrt_add_b),
	.L_msuOutA(Inv_sqrt_L_msu_a),
	.L_msuOutB(Inv_sqrt_L_msu_b),
	.L_msuOutC(Inv_sqrt_L_msu_c),
	.constantMemAddr(constantMemAddr),
	.done(Inv_sqrt_done),
	.out(Inv_sqrt_out));
					 
					 
	always @(posedge clk)
		begin
			if(reset)
				j <= 0;
			else
				j <= nextj;
		end

	always @(posedge clk)
		begin
			if(reset)
				i <= lag_max;
			else
				i <= nexti;
		end

	always @(posedge clk)
		begin
			if (reset)
				 state <= INIT;
			else
				 state <= nextstate;
		 end
		 
	always @(posedge clk)
		begin
			if(reset)
				p <= 0;
			else
				p <= next_p;
		end

	always @(posedge clk)
		begin
			if(reset)
				p1 <= 0;
			else
				p1 <= next_p1;
		end
	
	always @(posedge clk)
		begin
			if(reset)
				p_max <= 0;
			else
				p_max <= next_p_max;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				max_h <= 0;
			else
				max_h <= next_max_h;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				max_l <= 0;
			else
				max_l <= next_max_l;	
		end
		
	always @(posedge clk)
		begin
			if(reset)
				ener_h <= 0;
			else
				ener_h <= next_ener_h;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				ener_l <= 0;
			else
				ener_l <= next_ener_l;	
		end
		
	always @(posedge clk)
		begin
			if(reset)
				max <= 0;
			else
				max <= next_max;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				t0 <= 0;
			else
				t0 <= next_t0;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				L_temp <= 0;
			else
				L_temp <= next_L_temp;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				p_temp <= 0;
			else
				p_temp <= next_p_temp;	
		end
		
	always @(posedge clk)
		begin
			if(reset)
				cor_max <= 0;
			else
				cor_max <= next_cor_max;	
		end
		
	always @(posedge clk)
		begin
			if(reset)
				done <= 0;
			else
				done <= next_done;	
		end
		
		
	always@(*)
		begin
			writeAddr = 0;
			writeOut = 0;
			writeEn = 0;
			readAddr = 0;
			nextstate = state;
			nextj = j;
			nexti = i;
			next_p = p;
			next_p1 = p1;
			next_p_max = p_max;
			next_max_h = max_h;
			next_max_l = max_l;
			next_ener_h = ener_h;
			next_ener_l = ener_l;
			next_max = max;
			next_t0 = t0;
			next_L_temp = L_temp;
			next_p_temp = p_temp;
			next_cor_max = cor_max;
			next_done = done;
			L_mac_a = 0;
			L_mac_b = 0;
			L_mac_c = 0;
			L_msu_a = 0;
			L_msu_b = 0;
			L_msu_c = 0;
			sub_a = 0;
			sub_b = 0;
			L_sub_a = 0;
			L_sub_b = 0;
			add_a = 0;
			add_b = 0;
			L_add_a = 0;
			L_add_b = 0;
			Mpy_32_var1 = 0;
			Mpy_32_var2 = 0;
			Mpy_32_start = 0;
			Inv_sqrt_start = 0;
			
			case(state)
				INIT:
					begin
						if(start)
							begin
								next_max = 'd0;							//max = MIN_32;
								next_p_max = lag_max;					//p_max = lag_max;
								nexti = lag_max;
								nextstate = S1;
							end
					end
					
				S1:	//start of i loop
					begin
						if(i >= lag_min)
							begin
								next_p = signal;							//p = signal;
								sub_a = signal;
								sub_b = i;
								next_p1 = sub_in;							//p1 = &signal[-i];
								next_t0 = 'd0;									//t0 = 0;
								nextstate = S2;
							end
							
						else
							begin
								next_t0 = 'd0;								//t0 = 0;
								sub_a = signal;
								sub_b = p_max;
								next_p = sub_in;							//p = &signal[-p_max];
								nexti = 'd0;
								nextstate = S6;
							end
					end
					
				S2:	//start of j loop
					begin
						readAddr = p;
						nextstate = S3;
					end
					
				S3:
					begin
						next_p_temp = readIn;
						readAddr = p1;
						nextstate = S4;
					end
					
				S4: 
					begin
						if(j < L_frame)
							begin
								L_mac_a = p_temp;
								L_mac_b = readIn;
								L_mac_c = t0;								
								next_t0 = L_mac_in;							//t0 = Lmac(t0, *p, *p1);
								add_a = j;
								add_b = 1;
								nextj = add_in;								//j++
								nextstate = S5;
							end
							
						else
							begin
								L_sub_a = t0;
								L_sub_b = max;
								next_L_temp = L_sub_in;						//L_temp = L_sub(t0,max);
								if(L_sub_in[31] != 1)								//if(L_temp >= 0)
									begin
										next_max = t0;							//max = t0;
										next_p_max = i;						//p_max = i;
									end
								sub_a = i;
								sub_b = 'd1;
								nexti = sub_in;								//i--
								nextj = 'd0;
								nextstate = S1;
							end
					end	
					
				S5:
					begin
						add_a = p;
						add_b = 'd1;
						next_p = add_in;										//p++
						L_add_a = p1;
						L_add_b = 'd1;
						next_p1 = L_add_in[15:0];							//p1++
						nextstate = S2;
					end
					
				S6:
					begin
						readAddr = p;											
						nextstate = S7;
					end
					
				S7:
					begin
						if(i < L_frame)
							begin
								L_mac_a = readIn;
								L_mac_b = readIn;
								L_mac_c = t0;
								next_t0 = L_mac_in;									//t0 = L_mac(t0, *p, *p);
								add_a = i;
								add_b = 'd1;
								nexti = add_in;										//i++
								L_add_a = p;
								L_add_b = 'd1;
								next_p = L_add_in[15:0];							//p++
								nextstate = S6;
							end
							
						else
							begin
								nexti = 0;
								nextstate = S8;
							end
					end
					
				S8:
					begin
						sub_a = Inv_sqrt_sub_a;
						sub_b = Inv_sqrt_sub_b;
						L_shr_a = Inv_sqrt_L_shr_var1;
						L_shr_b = Inv_sqrt_L_shr_numshift;
						add_a = Inv_sqrt_add_a;
						add_b = Inv_sqrt_add_b;
						L_msu_a = Inv_sqrt_L_msu_a;
						L_msu_b = Inv_sqrt_L_msu_b;
						L_msu_c = Inv_sqrt_L_msu_c;
						Inv_sqrt_start = 1;
						if(Inv_sqrt_done == 1)
							begin
								next_t0 = Inv_sqrt_out;								//t0 = Inv_sqrt(t0);
								Inv_sqrt_start = 0;
								nextstate = S9;
							end
						else
							nextstate = S8;

					end
				S9:
					begin
							next_max_h = max[31:16];
							L_shr_a = max;
							L_shr_b = 'd1;
							L_msu_a = max[31:16];
							L_msu_b = 'd16384;
							L_msu_c = L_shr_in;
							next_max_l = L_msu_in[15:0];								//L_extract(max, &max_h, &max_l);
							nextstate = S10;
					end
					
				S10:
					begin					
						next_ener_h = t0[31:16];
						L_shr_a = t0;
						L_shr_b = 'd1;
						L_msu_a = t0[31:16];
						L_msu_b = 'd16384;
						L_msu_c = L_shr_in;
						next_ener_l = L_msu_in[15:0];								//L_extract(t0, &ener_h, &ener_l);
						nextstate = S11;
					end
					
				S11:
					begin
						Mpy_32_var1 = {max_h, max_l};
						Mpy_32_var2 = {ener_h, ener_l};
						L_mac_a = Mpy_32_L_mac_a;
						L_mac_b = Mpy_32_L_mac_b;
						L_mac_c = Mpy_32_L_mac_c;
						Mpy_32_start = 1;
						if(Mpy_32_done == 1)
							begin
								next_t0 = Mpy_32_out;								//t0 = Mpy32(max_h, max_l, ener_h, ener_l);
								next_cor_max = Mpy_32_out[15:0];					//*cor_max = extract_l(t0);
								next_done = 1;
								nextstate = S12;
							end
						else
							nextstate = S11;
					end
					
				S12:
					begin
						next_done = 0;
						nextstate = INIT;
					end
					
			endcase
			
		end
endmodule
