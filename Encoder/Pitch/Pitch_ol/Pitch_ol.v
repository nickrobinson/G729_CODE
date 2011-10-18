`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:54 04/06/2011 
// Design Name: 
// Module Name:    Pitch_ol 
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
module Pitch_ol(clk, start, reset, done, signal, pit_min, pit_max, L_frame, p_max1, writeAddr, writeOut, writeEn,
						readAddr, readIn, L_mac_a, L_mac_b, L_mac_c, L_mac_overflow, L_mac_in, mult_a, mult_b, mult_in, 
						shr_a, shr_b, shr_in, shl_a, shl_b, shl_in, add_a, add_b, add_in, sub_a, sub_b, sub_in, L_sub_a, 
						L_sub_b, L_sub_in, L_msu_a, L_msu_b, L_shr_b, L_msu_c, L_shr_a,
						L_add_a, L_add_b, L_mult_a, L_mult_b, L_mult_in, L_msu_in, L_shr_in, L_add_in, norm_l_in, 
						norm_l_done, L_shl_in, L_shl_done, constantMemIn, norm_l_var1, norm_l_ready, L_shl_var1, 
						L_shl_numshift, L_shl_ready, constantMemAddr);

	`include "paramList.v"

	input clk, start, reset;
	input [11:0] signal;
	input [15:0] L_frame, pit_max, pit_min;
	input [31:0] readIn;
	
	output reg done;
	output reg [11:0] writeAddr;
	output reg [31:0] writeOut;
	output reg writeEn;
	output reg [11:0] readAddr;
	output reg [15:0] p_max1;
	
	input [31:0] L_mac_in, L_sub_in;
	input L_mac_overflow;
	input [15:0] add_in, sub_in, mult_in;
	input [15:0] shr_in, shl_in;
	output reg [15:0] L_mac_a, L_mac_b;
	output reg [15:0] mult_a, mult_b;
	output reg [15:0] shr_a, shr_b;
	output reg [15:0] shl_a, shl_b;
	output reg [15:0] add_a, add_b, sub_a, sub_b;
	output reg [31:0] L_mac_c, L_sub_a, L_sub_b;
	
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
	parameter S13 = 13;
	parameter S14 = 14;
	
	reg [3:0] state, nextstate;
	reg [15:0] i, nexti, j, nextj;
	reg [15:0] max1, next_max1;
	reg [15:0] max2, next_max2;
	reg [15:0] max3, next_max3;
	reg [15:0] next_p_max1;
	reg [15:0] p_max2, next_p_max2;
	reg [15:0] p_max3, next_p_max3;
	reg [31:0] t0, next_t0;
	reg [31:0] L_temp, next_L_temp;
	reg [11:0] scaled_signal, next_scaled_signal;
	reg [11:0] scal_sig, next_scal_sig;
	reg [11:0] temp_sig, next_temp_sig;
	reg overflow, next_overflow;
	reg next_done;
	
	reg Lag_max_start;
	wire Lag_max_done;
	reg [11:0] Lag_max_signal;
	reg [15:0] lag_max;
	reg [15:0] lag_min;
	wire [15:0] cor_max;
	wire [15:0] p_max;
	wire [11:0] Lag_max_writeAddr;
	wire [31:0] Lag_max_writeOut;
	wire Lag_max_writeEn;
//	input [31:0] Lag_max_readIn;
//	wire [15:0] Lag_max_add_in, Lag_max_sub_in;
//	wire [31:0] Lag_max_L_mac_in, Lag_max_L_sub_in; 
	wire [15:0] Lag_max_add_a, Lag_max_add_b;
	wire [15:0] Lag_max_L_mac_a, Lag_max_L_mac_b;
	wire [15:0] Lag_max_sub_a, Lag_max_sub_b;
	wire [15:0] Lag_max_mult_a, Lag_max_mult_b;
	wire [31:0] Lag_max_L_mac_c;
	wire [31:0] Lag_max_L_sub_a, Lag_max_L_sub_b;	
	wire [15:0] Lag_max_shr_a, Lag_max_shr_b;
	wire [11:0] Lag_max_readAddr;
//	wire [15:0] Lag_max_shr_in, Lag_max_mult_in;
	output [15:0] L_msu_a, L_msu_b, L_shr_b;
	output [31:0] L_msu_c, L_shr_a;
	output [31:0] L_add_a, L_add_b;
	output [15:0] L_mult_a, L_mult_b;
	input [31:0] L_mult_in;
	input [31:0] L_msu_in, L_shr_in, L_add_in;
	input [15:0] norm_l_in;
	input norm_l_done;
	input [31:0] L_shl_in;
	input L_shl_done;
	input [31:0] constantMemIn;
	output [31:0] norm_l_var1;
	output norm_l_ready;
	output [31:0] L_shl_var1; 
	output [15:0] L_shl_numshift;
	output L_shl_ready;
	output [11:0] constantMemAddr;
	
	Lag_max i_Lag_max(
	.clk(clk), 
	.start(Lag_max_start), 
	.reset(reset), 
	.done(Lag_max_done), 
	.signal(Lag_max_signal), 
	.L_frame(L_frame), 
	.lag_max(lag_max), 
	.lag_min(lag_min), 
	.cor_max(cor_max), 
	.p_max(p_max), 
	.writeAddr(Lag_max_writeAddr), 
	.writeOut(Lag_max_writeOut), 
	.writeEn(Lag_max_writeEn), 
	.readAddr(Lag_max_readAddr), 
	.readIn(readIn), 
	.add_a(Lag_max_add_a), 
	.add_b(Lag_max_add_b), 
	.add_in(add_in), 
	.sub_a(Lag_max_sub_a),
	.sub_b(Lag_max_sub_b), 
	.sub_in(sub_in), 
	.L_mac_a(Lag_max_L_mac_a), 
	.L_mac_b(Lag_max_L_mac_b), 
	.L_mac_c(Lag_max_L_mac_c), 
	.L_mac_in(L_mac_in), 
	.L_sub_a(Lag_max_L_sub_a), 
	.L_sub_b(Lag_max_L_sub_b), 
	.L_sub_in(L_sub_in), 
	.L_msu_a(L_msu_a), 
	.L_msu_b(L_msu_b), 
	.L_msu_c(L_msu_c), 
	.L_msu_in(L_msu_in), 
	.L_shr_a(L_shr_a), 
	.L_shr_b(L_shr_b), 
	.L_shr_in(L_shr_in), 
	.L_add_a(L_add_a), 
	.L_add_b(L_add_b), 
	.L_add_in(L_add_in), 
	.L_mult_in(L_mult_in), 
	.mult_in(mult_in), 
	.L_mult_a(L_mult_a), 
	.L_mult_b(L_mult_b), 
	.mult_a(Lag_max_mult_a), 
	.mult_b(Lag_max_mult_b), 
	.norm_l_in(norm_l_in), 
	.norm_l_done(norm_l_done),
	.L_shl_in(L_shl_in),
	.L_shl_done(L_shl_done), 
	.shr_in(shr_in), 
	.constantMemIn(constantMemIn), 
	.constantMemAddr(constantMemAddr), 
	.norm_l_var1(norm_l_var1), 
	.norm_l_ready(norm_l_ready), 
	.L_shl_var1(L_shl_var1), 
	.L_shl_numshift(L_shl_numshift), 
	.L_shl_ready(L_shl_ready), 
	.shr_var1(Lag_max_shr_a), 
	.shr_var2(Lag_max_shr_b));
	
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
				i <= 0;
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
				max1 <= 0;
			else
				max1 <= next_max1;
		end
				
	always @(posedge clk)
		begin
			if(reset)
				max2 <= 0;
			else
				max2 <= next_max2;
		end
				
	always @(posedge clk)
		begin
			if(reset)
				max3 <= 0;
			else
				max3 <= next_max3;
		end

	always @(posedge clk)
		begin
			if(reset)
				p_max1 <= 0;
			else
				p_max1 <= next_p_max1;
		end
				
	always @(posedge clk)
		begin
			if(reset)
				p_max2 <= 0;
			else
				p_max2 <= next_p_max2;
		end
				
	always @(posedge clk)
		begin
			if(reset)
				p_max3 <= 0;
			else
				p_max3 <= next_p_max3;
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
				scaled_signal <= SCALED_SIGNAL;
			else
				scaled_signal <= next_scaled_signal;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				scal_sig <= 0;
			else
				scal_sig <= next_scal_sig;
		end

	always @(posedge clk)
		begin
			if(reset)
				temp_sig <= 0;
			else
				temp_sig <= next_temp_sig;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				overflow <= 0;
			else
				overflow <= next_overflow;
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
			next_done = done;
			writeAddr = 0;
			writeOut = 0;
			writeEn = 0;
			readAddr = 0;
			nextstate = state;
			nextj = j;
			nexti = i;
			next_p_max1 = p_max1;
			next_p_max2 = p_max2;
			next_p_max3 = p_max3;
			next_max1 = max1;
			next_max2 = max2;
			next_max3 = max3;
			next_t0 = t0;
			next_L_temp = L_temp;
			next_scaled_signal = scaled_signal;
			next_scal_sig = scal_sig;
			next_overflow = overflow;
			L_mac_a = 0;
			L_mac_b = 0;
			L_mac_c = 0;
			sub_a = 0;
			sub_b = 0;
			L_sub_a = 0;
			L_sub_b = 0;
			add_a = 0;
			add_b = 0;
			mult_a = 0;
			mult_b = 0;
			shr_a = 0;
			shr_b = 0;
			shl_a = 0;
			shl_b = 0;
			Lag_max_start = 0;
			Lag_max_signal = 0;
			lag_max = 0;
			lag_min = 0;
			
			case(state)
				INIT:
					begin
						if(start)
							begin
                                                                next_done = 0;
								add_a = scaled_signal;
								add_b = pit_max;
								next_scal_sig = add_in;						//scal_sig = &scaled_signal[pit_max];
								next_t0 = 0;									//t0 = 0;
								next_overflow = 0;							//Overflow = 0;
								sub_a = 0;
								sub_b = pit_max;
								nexti = sub_in;								//i = -pit_max
								nextstate = S1;
							end
						else
							nextstate = INIT;
					end
					
				S1:  	//start of i loop										//for(i=-pit_max; i<L_frame; i++)
					begin
						add_a = i;
						add_b = signal;
						readAddr = add_in;								
						nextstate = S2;
					end
					
				S2:	
					begin
						if(i == L_frame)
							begin
								sub_a = 0;
								sub_b = pit_max;
								nexti = sub_in;								//i = -pit_max
								nextstate = S3;
							end
							
						else
							begin
								L_mac_a = readIn;
								L_mac_b = readIn;
								L_mac_c = t0;
								next_t0 = L_mac_in;								//t0 = L_mac(t0, signal[i], signal[i]);
								if(L_mac_overflow)
									next_overflow = 1;
								add_a = i;
								add_b = 'd1;
								nexti = add_in;									//i++
								nextstate = S1;
							end
					end
				
				S3:
					begin
//						add_a = scal_sig;
//						add_b = i;
//						readAddr = add_in;								//readIn = scal_sig[i]
						nextstate = S4;
					end
					
				S4:
					begin						
						next_temp_sig = readIn;							//temp_sig = scal_sig[i]
						add_a = signal;
						add_b = i;
						readAddr = add_in;								//readIn = signal[i]
						nextstate = S5;
					end
				
				S5:
					begin
						if(overflow == 1)
							begin
								if((i[15] == 1) || (i < (L_frame-'d1)))
									begin
										shr_a = readIn;
										shr_b = 'd3;
										temp_sig = shr_in;						//scal_sig[i] = shr(signal[i], 3);
										writeOut = shr_in;
										nextstate = S3;
									end
								
								else
									nextstate = S6;
							end
							
						else
							begin
								if(t0 < 'd1048576)
									begin
										if((i[15] == 1) || (i < (L_frame-'d1)))
											begin
												shl_a = readIn;
												shl_b = 'd3;
												temp_sig = shl_in;						//scal_sig[i] = shl(signal[i], 3);
												writeOut = shl_in;
												nextstate = S3;
											end
										else
											nextstate = S6;
									end
								
								else
									begin
										if((i[15] == 1) || (i < (L_frame-'d1)))
											begin
												temp_sig = readIn;						//scal_sig[i] = signal[i];
												writeOut = readIn;
												nextstate = S3;
											end
										else
											nextstate = S6;
									end
							end
						 add_a = scal_sig;
						 add_b = i;
						 sub_a = i;
						 sub_b = 16'hffff;
						 nexti = sub_in;
  						 writeAddr = add_in;
						 writeEn = 1;
					end 
					
				S6:
					begin
						shl_a = pit_min;
						shl_b = 'd2;
						nextj = shl_in;												//j = shl(pit_min, 2);
						Lag_max_signal = scal_sig;
						lag_max = pit_max;
						lag_min = shl_in;
						
						readAddr = Lag_max_readAddr;
						add_a = Lag_max_add_a;
						add_b = Lag_max_add_b;
						L_mac_a = Lag_max_L_mac_a;
						L_mac_b = Lag_max_L_mac_b;
						sub_a = Lag_max_sub_a;
						sub_b = Lag_max_sub_b;
						mult_a = Lag_max_mult_a;
						mult_b = Lag_max_mult_b;
						L_mac_c = Lag_max_L_mac_c;
						L_sub_a = Lag_max_L_sub_a;
						L_sub_b = Lag_max_L_sub_b;
						shr_a = Lag_max_shr_a;
						shr_b = Lag_max_shr_b;
						
						Lag_max_start = 1;
						if(Lag_max_done == 1)
							begin
								next_max1 = cor_max;
								next_p_max1 = p_max;							//p_max1 = Lag_max(scal_sig, L_frame, pit_max, j, &max1);
								nextstate = S7;
							end
						else
							nextstate = S6;
					end
				
				S7:
					begin
						sub_a = j;
						sub_b = 'd1;
						nexti = sub_in;												//i = sub(j,1);
						shl_a = pit_min;
						shl_b = 'd1;
						nextj = shl_in;												//j = shl(pit_min, 1);
						nextstate = S8;
					end
				
				S8:
					begin
						Lag_max_signal = scal_sig;
						lag_max = i;
						lag_min = j;
						
						readAddr = Lag_max_readAddr;
						add_a = Lag_max_add_a;
						add_b = Lag_max_add_b;
						L_mac_a = Lag_max_L_mac_a;
						L_mac_b = Lag_max_L_mac_b;
						sub_a = Lag_max_sub_a;
						sub_b = Lag_max_sub_b;
						mult_a = Lag_max_mult_a;
						mult_b = Lag_max_mult_b;
						L_mac_c = Lag_max_L_mac_c;
						L_sub_a = Lag_max_L_sub_a;
						L_sub_b = Lag_max_L_sub_b;
						shr_a = Lag_max_shr_a;
						shr_b = Lag_max_shr_b;
						
						Lag_max_start = 1;
						if(Lag_max_done == 1)
							begin
								next_max2 = cor_max;
								next_p_max2 = p_max;							//p_max2 = Lag_max(scal_sig, L_frame, i, j, &max2);
								nextstate = S9;
							end
						else
							nextstate = S8;
					end
				
				S9:
					begin
						sub_a = j;
						sub_b = 'd1;
						nexti = sub_in;												//i = sub(j,1);
						nextstate = S10;
					end
				
				S10:
					begin

						Lag_max_signal = scal_sig;
						lag_max = i;
						lag_min = pit_min;
						
						readAddr = Lag_max_readAddr;
						add_a = Lag_max_add_a;
						add_b = Lag_max_add_b;
						L_mac_a = Lag_max_L_mac_a;
						L_mac_b = Lag_max_L_mac_b;
						sub_a = Lag_max_sub_a;
						sub_b = Lag_max_sub_b;
						mult_a = Lag_max_mult_a;
						mult_b = Lag_max_mult_b;
						L_mac_c = Lag_max_L_mac_c;
						L_sub_a = Lag_max_L_sub_a;
						L_sub_b = Lag_max_L_sub_b;
						shr_a = Lag_max_shr_a;
						shr_b = Lag_max_shr_b;
						
						Lag_max_start = 1;
						if(Lag_max_done == 1)
							begin
								next_max3 = cor_max;
								next_p_max3 = p_max;							//p_max3 = Lag_max(scal_sig, L_frame, i, pit_min, &max3);
								nextstate = S11;
							end
						else
							nextstate = S10;
					end
					
				S11:
					begin
						mult_a = max1;
						mult_b = 'd27853;
						sub_a = mult_in;
						sub_b = max2;
						if(sub_in[15] == 1)										//if(sub(mult(max1,THRESHPIT),max2)<0)
							begin 
								next_max1 = max2;										//max1 = max2;
								next_p_max1 = p_max2;								//p_max1 = p_max2;
								nextstate = S12;
							end
						else
							nextstate = S12;
					end
				
				S12:
					begin
						mult_a = max1;
						mult_b = 'd27853;
						sub_a = mult_in;
						sub_b = max3;
						if(sub_in[15] == 1)										//if(sub(mult(max1,THRESHPIT),max3)<0)
								next_p_max1 = p_max3;								//p_max1 = p_max3;
						next_done = 'd0;
						nextstate = S13;
					end

				S13:
					begin
						next_done = 'd1;
						writeAddr = T_OP;
						writeOut = p_max1;
						writeEn = 1;
						nextstate = S14;
					end

				S14:
				begin
					nextstate = INIT;
					next_done = 'd0;
				end
			endcase
		end
endmodule
