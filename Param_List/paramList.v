parameter AUTOCORR_Y		= 11'd0;						//Autocorr Y uses 256 blocks
parameter AUTOCORR_R		= 11'd256;					//Autocorr R uses 16 blocks
parameter LAG_WINDOW_R_PRIME 	= 11'd272;			//Lag window rPrime uses 16 blocks
parameter LSPGETQ_BUF 	= 11'd288;					//Lsp_get_quant's buf uses 16 blocks
parameter LEVINSON_DURBIN_ANEXT	= 11'd304;		//Levinson Durbin A next uses 16 blocks
parameter LEVINSON_DURBIN_AOLD	= 11'd320;		//Levinson Durbin A old uses 16 blocks
parameter LEVINSON_DURBIN_ATEMP	= 11'd336;		//Levinson Durbin A temp uses 16 blocks
parameter LEVINSON_DURBIN_RC	= 11'd352;			//Levinson Durbin RC uses 16 blocks
parameter LEVINSON_DURBIN_RCOLD	= 11'd368;		//Levinson Durbin RC old uses 16 blocks
parameter LSP_NEW		= 11'd384;						//lsp_new uses 16 blocks
parameter LSP_OLD		= 11'd400;						//lsp_old uses 16 blocks
parameter INTERPOLATION_LSF_INT = 11'd416;		//Interpolation lsfInt uses 16 blocks
parameter INTERPOLATION_LSF_NEW = 11'd432;		//Interpolation lsfNew uses 16 blocks
parameter PERC_VAR_GAMMA1 = 11'd448;				//Perceptual Adaptation gamma1 uses 2 blocks
parameter PERC_VAR_GAMMA2 = 11'd450;				//Perceptual Adaptation gamma2 uses 2 blocks
parameter PERC_VAR_LAR_OLD = 11'd452;				//Perceptual Adaptation Lar uses 2 blocks
parameter QUA_LSP_MODE_INDEX = 11'd454;			//Qua LSP mode_index uses 1 block
parameter LSP_SELECT_1_INDEX = 11'd455;			//LSP Select 1 Index uses 1 block
parameter PERC_VAR_LAR = 11'd456;					//Perceptual Adaptation Lar uses 4 blocks
parameter PERC_VAR_LAR_NEW = 11'd460;				//Perceptual Adaptation LarNew uses 4 blocks
parameter INT_LPC_LSP = 11'd464;						//INT_LPC LSP uses 16 blocks
parameter INT_LPC_F1 = 11'd480;						//INT_LPC F1 uses 8 blocks
parameter INT_LPC_F2 = 11'd488;						//INT_LPC F2 uses 8 blocks
parameter INT_LPC_LSP_TEMP = 11'd496;				//INT_LPC LSP Temp uses 16 blocks
parameter XX = 11'd512;									//OPEN 16 blocks
parameter WEIGHT_AZ_AP_OUT = 11'd528;				//Weight_Az AP uses 16 blocks
parameter RELSPWED_BUF = 11'd544;					//Relspwed buf uses 16 blocks
parameter FREQ_PREV = 11'd560;						//freq_prev uses 128 blocks
parameter LSP_SELECT_1_WEGT = 11'd688;				//LSP Select 1 WEGT uses 8 blocks
parameter XXXXXXX = 11'd696;							//OPEN 8 blocks
parameter XXXXXXXX = 11'd704;							//OPEN 16 blocks
parameter XXXXXXXXX = 11'd720;						//OPEN 32 blocks
parameter LSP_SELECT_1_RBUF = 11'd752;				//LSP Select 1 RBUF uses 8 blocks
parameter LSP_SELECT_1_BUF = 11'd760;				//LSP Select 1 internal Buf uses 8 blocks
parameter A_T = 11'd768;								//A_t uses 32 Blocks
parameter AQ_T = 11'd800;								//Aq_t uses 32 Blocks
parameter SYN_FILT_TEMP = 11'd832;					//syn filt temp uses 128 Blocks
parameter COR_H = 11'd960;								//Cor_h uses 64 Blocks
parameter ACELP_RR = 11'd1024;						//Acelp rr uses 640 blocks
parameter ACELP_H = 11'd1664;							//Acelp h uses 64 blocks
parameter xxxxxxxxxxxxxxxxxxxxxxxxx					//OPEN 2048 blocks
