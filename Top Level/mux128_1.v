`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    10:14:52 11/26/2010
// Module Name:    128_1bit_mux 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a 128 input, 1 bit multiplexor.
//
// Dependencies: 	N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux128_1(in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,
			in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,in24,in25,in26,in27,in28,
			in29,in30,in31,in32,in33,in34,in35,in36,in37,in38,in39,in40,in41,in42,in43,
			in44,in45,in46,in47,in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,
			in59,in60,in61,in62,in63,in64,in65,in66,in67,in68,in69,in70,in71,in72,in73,
			in74,in75,in76,in77,in78,in79,in80,in81,in82,in83,in84,in85,in86,in87,in88,
			in89,in90,in91,in92,in93,in94,in95,in96,in97,in98,in99,in100,in101,in102,in103,
			in104,in105,in106,in107,in108,in109,in110,in111,in112,in113,in114,in115,in116,
			in117,in118,in119,in120,in121,in122,in123,in124,in125,in126,in127,sel,out);
			
			
    input in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13,
						in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,in24,in25,in26,in27,in28,
						in29,in30,in31,in32,in33,in34,in35,in36,in37,in38,in39,in40,in41,in42,in43,
						in44,in45,in46,in47,in48,in49,in50,in51,in52,in53,in54,in55,in56,in57,in58,
						in59,in60,in61,in62,in63,in64,in65,in66,in67,in68,in69,in70,in71,in72,in73,
						in74,in75,in76,in77,in78,in79,in80,in81,in82,in83,in84,in85,in86,in87,in88,
						in89,in90,in91,in92,in93,in94,in95,in96,in97,in98,in99,in100,in101,in102,in103,
						in104,in105,in106,in107,in108,in109,in110,in111,in112,in113,in114,in115,in116,
						in117,in118,in119,in120,in121,in122,in123,in124,in125,in126,in127;
    input [5:0] sel;
    output reg out;


	always @(*) begin

		case (sel)
			'd0: out = in0;
			'd1: out = in1;
			'd2: out = in2;
			'd3: out = in3;
			'd4: out = in4;
			'd5: out = in5;
			'd6: out = in6;
			'd7: out = in7;
			'd8: out = in8;
			'd9: out = in9;
			'd10: out = in10;
			'd11: out = in11;
			'd12: out = in12;
			'd13: out = in13;
			'd14: out = in14;
			'd15: out = in15;
			'd16: out = in16;
			'd17: out = in17;
			'd18: out = in18;
			'd19: out = in19;
			'd20: out = in20;
			'd21: out = in21;
			'd22: out = in22;
			'd23: out = in23;
			'd24: out = in24;
			'd25: out = in25;
			'd26: out = in26;
			'd27: out = in27;
			'd28: out = in28;
			'd29: out = in29;
			'd30: out = in30;
			'd31: out = in31;
			'd32: out = in32;
			'd33: out = in33;
			'd34: out = in34;
			'd35: out = in35;
			'd36: out = in36;
			'd37: out = in37;
			'd38: out = in38;
			'd39: out = in39;
			'd40: out = in40;
			'd41: out = in41;
			'd42: out = in42;
			'd43: out = in43;
			'd44: out = in44;
			'd45: out = in45;
			'd46: out = in46;
			'd47: out = in47;
			'd48: out = in48;
			'd49: out = in49;
			'd50: out = in50;
			'd51: out = in51;
			'd52: out = in52;
			'd53: out = in53;
			'd54: out = in54;
			'd55: out = in55;
			'd56: out = in56;
			'd57: out = in57;
			'd58: out = in58;
			'd59: out = in59;
			'd60: out = in60;
			'd61: out = in61;
			'd62: out = in62;
			'd63: out = in63;
			'd64: out = in64;
			'd65: out = in65;
			'd66: out = in66;
			'd67: out = in67;
			'd68: out = in68;
			'd69: out = in69;
			'd70: out = in70;
			'd71: out = in71;
			'd72: out = in72;
			'd73: out = in73;
			'd74: out = in74;
			'd75: out = in75;
			'd76: out = in76;
			'd77: out = in77;
			'd78: out = in78;
			'd79: out = in79;
			'd80: out = in80;
			'd81: out = in81;
			'd82: out = in82;
			'd83: out = in83;
			'd84: out = in84;
			'd85: out = in85;
			'd86: out = in86;
			'd87: out = in87;
			'd88: out = in88;
			'd89: out = in89;
			'd90: out = in90;
			'd91: out = in91;
			'd92: out = in92;
			'd93: out = in93;
			'd94: out = in94;
			'd95: out = in95;
			'd96: out = in96;
			'd97: out = in97;
			'd98: out = in98;
			'd99: out = in99;
			'd100: out = in100;
			'd101: out = in101;
			'd102: out = in102;
			'd103: out = in103;
			'd104: out = in104;
			'd105: out = in105;
			'd106: out = in106;
			'd107: out = in107;
			'd108: out = in108;
			'd109: out = in109;
			'd110: out = in110;
			'd111: out = in111;
			'd112: out = in112;
			'd113: out = in113;
			'd114: out = in114;
			'd115: out = in115;
			'd116: out = in116;
			'd117: out = in117;
			'd118: out = in118;
			'd119: out = in119;
			'd120: out = in120;
			'd121: out = in121;
			'd122: out = in122;
			'd123: out = in123;
			'd124: out = in124;
			'd125: out = in125;
			'd126: out = in126;
			'd127: out = in127;
			
		endcase
	end

endmodule

