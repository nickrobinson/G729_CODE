`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    08:45:50 09/17/2010
// Module Name:    hammingWindowMemory.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a memory block for accessing specific hamming window constants. See the "hamwindow" 
//						array in the "tab_ld8k.c" file for reference
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module hammingWindowMemory(in, out);

input [7:0] in;
output reg [15:0] out;

always @(*) begin

case (in)
	'd0: out = 16'd2621;
	'd1: out = 16'd2623;
	'd2: out = 16'd2629;
	'd3: out = 16'd2638;
	'd4: out = 16'd2651;
	'd5: out = 16'd2668;
	'd6: out = 16'd2689;
	'd7: out = 16'd2713;
	'd8: out = 16'd2741;
	'd9: out = 16'd2772;
	'd10: out = 16'd2808;
	'd11: out = 16'd2847;
	'd12: out = 16'd2890;
	'd13: out = 16'd2936;
	'd14: out = 16'd2986;
	'd15: out = 16'd3040;
	'd16: out = 16'd3097;
	'd17: out = 16'd3158;
	'd18: out = 16'd3223;
	'd19: out = 16'd3291; 
	'd20: out = 16'd3363;
	'd21: out = 16'd3438;
	'd22: out = 16'd3517;
	'd23: out = 16'd3599;
	'd24: out = 16'd3685;
	'd25: out =	16'd3774;
	'd26: out = 16'd3867;
	'd27: out =	16'd3963;
	'd28: out = 16'd4063;
	'd29: out = 16'd4166;
	'd30: out = 16'd4272;
	'd31: out = 16'd4382; 
	'd32: out = 16'd4495;
	'd33: out =	16'd4611;
	'd34: out =	16'd4731;
	'd35: out = 16'd4853;
	'd36: out =	16'd4979;
	'd37: out = 16'd5108;
	'd38: out =	16'd5240;
	'd39: out =	16'd5376;
	'd40: out =	16'd5514;
	'd41: out =	16'd5655;
	'd42: out = 16'd5800;
	'd43: out =	16'd5947;
	'd44: out =	16'd6097;
	'd45: out =	16'd6250;
	'd46: out =	16'd6406;
	'd47: out =	16'd6565;
	'd48: out =	16'd6726;
	'd49: out = 16'd6890;
	'd50: out =	16'd7057;
	'd51: out =	16'd7227;
	'd52: out =	16'd7399;
	'd53: out =	16'd7573;
	'd54: out =	16'd7750;
	'd55: out = 16'd7930;
	'd56: out = 16'd8112;
	'd57: out =	16'd8296;
	'd58: out = 16'd8483;
	'd59: out =	16'd8672;
	'd60: out =	16'd8863;
	'd61: out =	16'd9057;
	'd62: out = 16'd9252;
	'd63: out = 16'd9450;
	'd64: out = 16'd9650;
	'd65: out = 16'd9852;
	'd66: out = 16'd10055;
	'd67: out = 16'd10261;
	'd68: out = 16'd10468;
	'd69: out = 16'd10677;
	'd70: out =	16'd10888;
	'd71: out = 16'd11101; 
	'd72: out = 16'd11315;
	'd73: out = 16'd11531;
	'd74: out = 16'd11748;
	'd75: out = 16'd11967;
	'd76: out = 16'd12187;
	'd77: out =	16'd12409;
	'd78: out = 16'd12632;
	'd79: out = 16'd12856;
	'd80: out = 16'd13082;
	'd81: out = 16'd13308;
	'd82: out = 16'd13536;
	'd83: out = 16'd13764;
	'd84: out = 16'd13994;
	'd85: out = 16'd14225;
	'd86: out = 16'd14456;
	'd87: out = 16'd14688; 
	'd88: out = 16'd14921;
	'd89: out = 16'd15155;
	'd90: out = 16'd15389;
	'd91: out = 16'd15624;
	'd92: out = 16'd15859;
	'd93: out = 16'd16095;
	'd94: out = 16'd16331;
	'd95: out = 16'd16568;
	'd96: out = 16'd16805;
	'd97: out = 16'd17042;
	'd98: out =	16'd17279;
	'd99: out = 16'd17516;
	'd100: out = 16'd17754;
	'd101: out = 16'd17991;
	'd102: out = 16'd18228;
	'd103: out = 16'd18465;
	'd104: out = 16'd18702;
	'd105: out = 16'd18939;
	'd106: out = 16'd19175;
	'd107: out = 16'd19411;
	'd108: out = 16'd19647;
	'd109: out = 16'd19882;
	'd110: out = 16'd20117;
	'd111: out = 16'd20350;
	'd112: out = 16'd20584;
	'd113: out =16'd20816;
	'd114: out = 16'd21048;
	'd115: out = 16'd21279;
	'd116: out = 16'd21509;
	'd117: out = 16'd21738;
	'd118: out = 16'd21967;
	'd119: out = 16'd22194;
	'd120: out = 16'd22420;
	'd121: out = 16'd22644;
	'd122: out = 16'd22868;
	'd123: out = 16'd23090;
	'd124: out = 16'd23311;
	'd125: out = 16'd23531;
	'd126: out = 16'd23749;
	'd127: out = 16'd23965;
	'd128: out = 16'd24181;
	'd129: out = 16'd24394;
	'd130: out = 16'd24606;
	'd131: out = 16'd24816;
	'd132: out = 16'd25024;
	'd133: out = 16'd25231;
	'd134: out = 16'd25435;
	'd135: out = 16'd25638;
	'd136: out = 16'd25839;
	'd137: out = 16'd26037;
	'd138: out = 16'd26234;
	'd139: out = 16'd26428;
	'd140: out = 16'd26621;
	'd141: out = 16'd26811;
	'd142: out = 16'd26999;
	'd143: out = 16'd27184;
	'd144: out = 16'd27368;
	'd145: out = 16'd27548;
	'd146: out = 16'd27727;
	'd147: out = 16'd27903;
	'd148: out = 16'd28076;
	'd149: out = 16'd28247;
	'd150: out = 16'd28415;
	'd151: out = 16'd28581;
	'd152: out = 16'd28743;
	'd153: out = 16'd28903;
	'd154: out = 16'd29061;
	'd155: out = 16'd29215;
	'd156: out = 16'd29367;
	'd157: out = 16'd29515;
	'd158: out = 16'd29661;
	'd159: out = 16'd29804;
	'd160: out = 16'd29944;
	'd161: out = 16'd30081;
	'd162: out = 16'd30214;
	'd163: out = 16'd30345;
	'd164: out = 16'd30472;
	'd165: out = 16'd30597;
	'd166: out = 16'd30718;
	'd167: out = 16'd30836;
	'd168: out = 16'd30950;
	'd169: out = 16'd31062;
	'd170: out = 16'd31170;
	'd171: out = 16'd31274;
	'd172: out = 16'd31376;
	'd173: out = 16'd31474;
	'd174: out = 16'd31568;
	'd175: out = 16'd31659;
	'd176: out = 16'd31747;
	'd177: out = 16'd31831;
	'd178: out = 16'd31911;
	'd179: out = 16'd31988;
	'd180: out = 16'd32062;
	'd181: out = 16'd32132;
	'd182: out = 16'd32198;
	'd183: out = 16'd32261;
	'd184: out = 16'd32320;
	'd185: out = 16'd32376;
	'd186: out = 16'd32428;
	'd187: out = 16'd32476;
	'd188: out = 16'd32521;
	'd189: out = 16'd32561;
	'd190: out = 16'd32599;
	'd191: out = 16'd32632;
	'd192: out = 16'd32662;
	'd193: out = 16'd32688;
	'd194: out = 16'd32711;
	'd195: out = 16'd32729;
	'd196: out = 16'd32744;
	'd197: out = 16'd32755;
	'd198: out = 16'd32763;
	'd199: out = 16'd32767;
	'd200: out = 16'd32767;
	'd201: out = 16'd32741;
	'd202: out = 16'd32665;
	'd203: out = 16'd32537;
	'd204: out = 16'd32359;
	'd205: out = 16'd32129;
	'd206: out = 16'd31850;
	'd207: out = 16'd31521;
	'd208: out = 16'd31143;
	'd209: out = 16'd30716;
	'd210: out = 16'd30242;
	'd211: out = 16'd29720;
	'd212: out = 16'd29151;
	'd213: out = 16'd28538;
	'd214: out = 16'd27879;
	'd215: out = 16'd27177;
	'd216: out = 16'd26433;
	'd217: out = 16'd25647;
	'd218: out = 16'd24821;
	'd219: out = 16'd23957;
	'd220: out = 16'd23055;
	'd221: out = 16'd22117;
	'd222: out = 16'd21145;
	'd223: out = 16'd20139;
	'd224: out = 16'd19102;
	'd225: out = 16'd18036;
	'd226: out = 16'd16941;
	'd227: out = 16'd15820;
	'd228: out = 16'd14674;
	'd229: out = 16'd13505;
	'd230: out = 16'd12315;
	'd231: out = 16'd11106;
	'd232: out = 16'd9879;
	'd233: out = 16'd8637;
	'd234: out = 16'd7381;
	'd235: out = 16'd6114;
	'd236: out = 16'd4838;
	'd237: out = 16'd3554;
	'd238: out = 16'd2264;
	'd239: out = 16'd971;
endcase
end



endmodule
