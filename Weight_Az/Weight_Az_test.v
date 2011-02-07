`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:37:41 01/27/2011
// Design Name:   Weight_Az
// Module Name:   C:/XilinxProjects/weight_az/Weight_Az_test.v
// Project Name:  weight_az
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Weight_Az
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Weight_Az_test_v;
`include "paramList.v"

	// Inputs
	reg start;
	reg clk;
	reg reset;
	reg [10:0] A;
	reg [10:0] AP;
	reg [10:0] gammaAddr;	
	
	wire done;
	wire [31:0] readIn;
	wire [31:0] L_mult_in;
	wire [31:0] L_add_in;
	wire [15:0] add_in;

	// Outputs
	wire [10:0] readAddr;
	wire [10:0] writeAddr;
	wire [31:0] writeOut;
	wire writeEn;
	wire [15:0] L_mult_a;
	wire [15:0] L_mult_b;
	wire [15:0] add_a;
	wire [15:0] add_b;
	wire [31:0] L_add_a;
	wire [31:0] L_add_b;
	
	
	//intermediary wires
	wire [31:0] memIn;
	
	
	
	
	
	integer i, j;
	
	//Mux0 regs	
	reg wazMuxSel;
	reg [10:0] wazMuxOut;
	reg [10:0] wazReadRequested;
	//mux1 regs
	reg wazMux1Sel;
	reg [10:0] wazMux1Out;
	reg [10:0] wazWriteRequested;
	//mux2 regs
	reg wazMux2Sel;
	reg [31:0] wazMux2Out;
	reg [31:0] wazOut;
	//mux3regs
	reg wazMux3Sel;
	reg wazMux3Out;
	reg wazWrite;
	

	//I/O regs
	//working regs
	reg [15:0] ac [0:9999];
	reg [15:0] gammac [0:9999];
	reg [15:0] apc [0:399];


	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("WEIGHT_AZ_A_IN.out", ac);
			$readmemh("WEIGHT_AZ_GAMMA_IN.out", gammac);
			$readmemh("WEIGHT_AZ_AP_OUT.out", apc);
		end
		
		
		

	// Instantiate the Unit Under Test (UUT)
	Weight_Az uut (
		.start(start), 
		.clk(clk), 
		.done(done), 
		.reset(reset), 
		.A(A), 
		.AP(AP), 
		.gammaAddr(gammaAddr), 
		.readAddr(readAddr), 
		.readIn(readIn), 
		.writeAddr(writeAddr), 
		.writeOut(writeOut), 
		.writeEn(writeEn), 
		.L_mult_in(L_mult_in), 
		.L_add_in(L_add_in), 
		.add_in(add_in), 
		.L_mult_a(L_mult_a), 
		.L_mult_b(L_mult_b), 
		.add_a(add_a), 
		.add_b(add_b), 
		.L_add_a(L_add_a), 
		.L_add_b(L_add_b)
	);
	
	
	always @(*)
	begin
		case	(wazMuxSel)	
			'd0 :	wazMuxOut = wazReadRequested;
			'd1:	wazMuxOut = readAddr;
		endcase
	end
	
	//lsp write address mux
	always @(*)
	begin
		case	(wazMux1Sel)	
			'd0 :	wazMux1Out = wazWriteRequested;
			'd1:	wazMux1Out = writeAddr;
		endcase
	end
	
	//lsp write input mux
	always @(*)
	begin
		case	(wazMux2Sel)	
			'd0 :	wazMux2Out = wazOut;
			'd1:	wazMux2Out = writeOut;
		endcase
	end
	
	//lsp write enable mux
	always @(*)
	begin
		case	(wazMux3Sel)	
			'd0 :	wazMux3Out = wazWrite;
			'd1:	wazMux3Out = writeEn;
		endcase
	end
	
	
	Scratch_Memory_Controller testMem(
												 .addra(wazMux1Out),
												 .dina(wazMux2Out),
												 .wea(wazMux3Out),
												 .clk(clk),
												 .addrb(wazMuxOut),
												 .doutb(readIn)
												 );
												 
	
	
	
	L_mult Weight_Az_L_mult(
						 .a(L_mult_a),
						 .b(L_mult_b),
						 .overflow(),
						 .product(L_mult_in)
						 );
						 
	L_add Weight_Az_L_add(
					.a(L_add_a),
					.b(L_add_b),
					.overflow(),
					.sum(L_add_in)
					);	
	
	add Weight_Az_add(
					.a(add_a),
					.b(add_b),
					.overflow(),
					.sum(add_in)
					);
	

	initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		A = 11'd496;
		AP = 11'd512;
		gammaAddr = 11'd448;
		
		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			wazMuxSel = 1;
			wazMux1Sel = 0;
			wazMux2Sel = 0;
			wazMux3Sel = 0;
			wazWrite = 0;
			
			for(i=0;i<11;i=i+1)
			begin
				#100;
				wazWriteRequested = {WEIGHT_AZ_A_IN[10:4],i[3:0]};
				wazOut = ac[11*j+i];
				wazWrite = 1;	
				#100;			
			end
			
			#100;
				wazWriteRequested = {PERC_VAR_GAMMA1[10:0]};
				wazOut = gammac[j];
				wazWrite = 1;	
				#100;
			
			wazMux1Sel = 1;
			wazMux2Sel = 1;
			wazMux3Sel = 1;		
	
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			wazMuxSel = 0;
			

			
			//ap read
			for (i = 0; i<11;i=i+1)
			begin				
					wazReadRequested = {WEIGHT_AZ_AP_OUT[10:4],i[3:0]};
					@(posedge clk);
					@(posedge clk);
					if (readIn != apc[j*11+i])
						$display($time, " ERROR: apc[%d] = %x, expected = %x", j*11+i, readIn, apc[j*11+i]);
					else if (readIn == apc[j*11+i])
						$display($time, " CORRECT:  apc[%d] = %x", j*11+i, readIn);
					@(posedge clk);
			end	
				
		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	       
endmodule

