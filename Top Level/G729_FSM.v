`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    14:13:23 10/14/2010 
// Module Name:    G729_FSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Top Level FSM Controller for G.729 Encoder. Signals each sub-module 
//						 to begin at the appropriate time.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module G729_FSM(clock, reset,start,divErr,frame_done,autocorrDone,lagDone,levinsonDone,AzDone,
					 Qua_lspDone,Int_lpcDone,Int_qlpcDone,Math1Done,mathMuxSel,autocorrReady,lagReady,levinsonReady,
					 AzReady,Qua_lspReady,Int_lpcReady,Int_qlpcReady,Math1Ready,done);
    
	 //inputs
	 input clock;
    input reset;
	 input start;
	 input divErr;
	 input frame_done;
	 input autocorrDone;
	 input lagDone;
	 input levinsonDone;
	 input AzDone;
	 input Qua_lspDone;
	 input Int_lpcDone;
 	 input Int_qlpcDone;
	 input Math1Done;
	 
	 ///outputs
	 output reg [5:0] mathMuxSel;
	 output reg autocorrReady;
	 output reg lagReady;
	 output reg levinsonReady;
	 output reg AzReady;
	 output reg Qua_lspReady;
	 output reg Int_lpcReady;
	 output reg Int_qlpcReady;
	 output reg Math1Ready;
	 output reg done;
	 
	 parameter INIT = 3'd0;
	 parameter S0 = 3'd1;
	 parameter S1 = 3'd2;
	 parameter SUB_MODULE_START = 5'd0;
	 parameter SUB_MODULE_AUTOCORR_READY = 5'd1;
	 parameter SUB_MODULE_AUTOCORR_DONE = 5'd2;
	 parameter SUB_MODULE_LAG_DONE = 5'd3;
	 parameter SUB_MODULE_LEVINSON_DONE = 5'd4;
	 parameter SUB_MODULE_AZ_DONE = 5'd5;
	 parameter SUB_MODULE_QUA_LSP_DONE = 5'd6;
	 parameter SUB_MODULE_INT_LPC_DONE = 5'd7;
 	 parameter SUB_MODULE_INT_QLPC_DONE = 5'd8;
	 parameter SUB_MODULE_MATH1_DONE = 5'd9;

	 
	 //working regs
	 reg [2:0] frameDoneState, nextFrameDoneState;
	 reg [2:0] frameDoneCount,frameDoneCountLoad,frameDoneCountReset;	
	 reg [4:0] subModuleState,nextsubModuleState;
	 
	//autocorr ready state machine flop
		always @(posedge clock)
		begin
			if(reset)
				frameDoneState <= 0;
			else
				frameDoneState <= nextFrameDoneState;	
		end
	 
	//autocorr ready frame counter flop
		always @(posedge clock)
		begin
			if(reset)
				frameDoneCount <= 0;
			else if(frameDoneCountReset)
				frameDoneCount <= 0;
			else if(frameDoneCountLoad)
				frameDoneCount <= frameDoneCount + 1;
		end
		
		//submodule ready/done state machine flop
		always @(posedge clock)
		begin
			if(reset)
				subModuleState <= 0;
			else
				subModuleState <= nextsubModuleState;
			
		end
	
	 //Sub-Module state machine
	 always@(*)
	 begin
	 
		mathMuxSel = 0;
		done = 0;
		nextsubModuleState = subModuleState;
		lagReady = 0;
		levinsonReady = 0;
		AzReady = 0;
		Qua_lspReady = 0;
		Int_lpcReady = 0;
		Int_qlpcReady = 0;
		Math1Ready = 0;
		
		if(divErr == 1)
			nextsubModuleState = SUB_MODULE_START;
			
		case(subModuleState)
		
		SUB_MODULE_START:
		begin
			if(start == 0)
				nextsubModuleState = SUB_MODULE_START;
			else if(start == 1)
				nextsubModuleState = SUB_MODULE_AUTOCORR_READY;
		end	//SUB_MODULE_START
		
		SUB_MODULE_AUTOCORR_READY:
		begin
			if(autocorrReady == 0)
				nextsubModuleState = SUB_MODULE_AUTOCORR_READY;
			else if(autocorrReady == 1)
			begin
				nextsubModuleState = SUB_MODULE_AUTOCORR_DONE;
				mathMuxSel = 6'd0;
			end
		end//SUB_MODULE_AUTOCORR_READY
		
		SUB_MODULE_AUTOCORR_DONE:
		begin
			mathMuxSel = 6'd0;
			if(autocorrDone == 0)
				nextsubModuleState = SUB_MODULE_AUTOCORR_DONE;
			else if(autocorrDone == 1)
			begin	
				
				mathMuxSel = 6'd1;
				lagReady = 1;
				nextsubModuleState = SUB_MODULE_LAG_DONE; 
			end				
		end//SUB_MODULE_AUTOCORR_DONE
		
		SUB_MODULE_LAG_DONE:
		begin
			mathMuxSel = 6'd1;
			if(lagDone == 0)
				nextsubModuleState = SUB_MODULE_LAG_DONE;
			else if(lagDone == 1)
			begin				
				mathMuxSel = 6'd2;
				nextsubModuleState = SUB_MODULE_LEVINSON_DONE;
				levinsonReady = 1;
			end				
		end//SUB_MODULE_AUTOCORR_DONE
		
		SUB_MODULE_LEVINSON_DONE:
		begin
			mathMuxSel = 6'd2;
			if(levinsonDone == 0)
				nextsubModuleState = SUB_MODULE_LEVINSON_DONE;
			else if(levinsonDone == 1)
			begin					
				mathMuxSel = 6'd3;
				nextsubModuleState = SUB_MODULE_AZ_DONE;
				AzReady = 1;		
			end				
		end//SUB_MODULE_LEVINSON_DONE
		
		SUB_MODULE_AZ_DONE:
		begin
			mathMuxSel = 6'd3;
			if(AzDone == 0)
				nextsubModuleState = SUB_MODULE_AZ_DONE;
			else if(AzDone == 1)
			begin
				mathMuxSel = 6'd4;
				nextsubModuleState = SUB_MODULE_QUA_LSP_DONE;
				Qua_lspReady = 1;
			end				
		end//SUB_MODULE_AZ_DONE		
		
		SUB_MODULE_QUA_LSP_DONE:
		begin
			mathMuxSel = 6'd4;
			if(Qua_lspDone == 0)
				nextsubModuleState = SUB_MODULE_QUA_LSP_DONE;
			else if(Qua_lspDone == 1)
			begin
				mathMuxSel = 6'd5;
				nextsubModuleState = SUB_MODULE_INT_LPC_DONE;
				Int_lpcReady = 1;
			end				
		end//SUB_MODULE_QUA_LSP_DONE		
		
		SUB_MODULE_INT_LPC_DONE:
		begin
			mathMuxSel = 6'd5;
			if(Int_lpcDone == 0)
				nextsubModuleState = SUB_MODULE_INT_LPC_DONE;
			else if(Int_lpcDone == 1)
			begin
				mathMuxSel = 6'd6;
				nextsubModuleState = SUB_MODULE_INT_QLPC_DONE;
				Int_qlpcReady = 1;
			end				
		end//SUB_MODULE_INT_LPC_DONE		
		
		SUB_MODULE_INT_QLPC_DONE:
		begin
			mathMuxSel = 6'd6;
			if(Int_qlpcDone == 0)
				nextsubModuleState = SUB_MODULE_INT_QLPC_DONE;
			else if(Int_qlpcDone == 1)
			begin
				mathMuxSel = 6'd7;
				nextsubModuleState = SUB_MODULE_MATH1_DONE;
				Math1Ready = 1;
			end				
		end//SUB_MODULE_INT_QLPC_DONE		
		
		SUB_MODULE_MATH1_DONE:
		begin
			mathMuxSel = 6'd7;
			if(Math1Done == 0)
				nextsubModuleState = SUB_MODULE_MATH1_DONE;
			else if(Math1Done == 1)
			begin
				mathMuxSel = 6'd8;
				nextsubModuleState = SUB_MODULE_START;
				done = 1;
			end				
		end//SUB_MODULE_MATH1_DONE		



		endcase
		
	 end//Sub-Module state machine
	 
	 //Autocorr Ready state machine
	 always @(*)
	 begin	//always
	 
		nextFrameDoneState = frameDoneState;
		frameDoneCountReset = 0;
		frameDoneCountLoad = 0;
		autocorrReady = 0;
		
		case(frameDoneState)
		
		INIT: 
		begin	//INIT
			if(start == 0)
				nextFrameDoneState = INIT;
			else if(start == 1)
			begin
				nextFrameDoneState = S0;
			end//else if(start == 1)
		end	//INIT
		
		S0:
		begin
			if(frame_done)
					frameDoneCountLoad = 1;
					
				if(frameDoneCount == 2'd2)
				begin	//count
						frameDoneCountReset = 1;
						autocorrReady = 1;
						nextFrameDoneState = S1;
				end	//count
				
				else
					nextFrameDoneState = S0;
		end
		
		S1: 
		begin //S1
		
			if(frame_done)
					frameDoneCountLoad = 1;
					
			if(frameDoneCount == 2'd2)
			begin	//count
					frameDoneCountReset = 1;
					autocorrReady = 1;
					nextFrameDoneState = S1;
			end//count
			
			else
				nextFrameDoneState = S1;
		
		end	//S1
		endcase
	end	//always


endmodule
