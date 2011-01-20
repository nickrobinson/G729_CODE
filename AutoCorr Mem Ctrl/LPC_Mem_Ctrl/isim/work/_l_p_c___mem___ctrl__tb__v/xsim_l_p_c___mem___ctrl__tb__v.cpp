static const char * HSimCopyRightNotice = "Copyright 2004-2005, Xilinx Inc. All rights reserved.";
#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


static HSim__s6* IF0(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createworkM_l_p_c___mem___ctrl__tb__v(const char*);
    HSim__s6 *blk = createworkM_l_p_c___mem___ctrl__tb__v(label); 
    return blk;
}


static HSim__s6* IF1(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage(const char*);
    HSim__s6 *blk = createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage(label); 
    return blk;
}


static HSim__s6* IF2(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4(const char*);
    HSim__s6 *blk = createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4(label); 
    return blk;
}


static HSim__s6* IF3(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4(const char*);
    HSim__s6 *blk = createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4(label); 
    return blk;
}


static HSim__s6* IF4(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4(const char*);
    HSim__s6 *blk = createxilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4(label); 
    return blk;
}


static HSim__s6* IF5(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createworkM_auto_corr__mem__1(const char*);
    HSim__s6 *blk = createworkM_auto_corr__mem__1(label); 
    return blk;
}


static HSim__s6* IF6(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createworkM_l_p_c___mem___ctrl(const char*);
    HSim__s6 *blk = createworkM_l_p_c___mem___ctrl(label); 
    return blk;
}


static HSim__s6* IF7(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    extern HSim__s6 * createworkMglbl(const char*);
    HSim__s6 *blk = createworkMglbl(label); 
    return blk;
}

class _top : public HSim__s6 {
public:
    _top() : HSim__s6(false, "_top", "_top", 0, 0, HSim::VerilogModule) {}
    HSimConfigDecl * topModuleInstantiate() {
        HSimConfigDecl * cfgvh = 0;
        cfgvh = new HSimConfigDecl("default");
        (*cfgvh).registerFuseLibList("unisims_ver;xilinxcorelib_ver");

        (*cfgvh).addVlogModule("work","LPC_Mem_Ctrl_tb_v", (HSimInstFactoryPtr)IF0);
        (*cfgvh).addVlogModule("xilinxcorelib_ver","BLK_MEM_GEN_V2_4_output_stage", (HSimInstFactoryPtr)IF1);
        (*cfgvh).addVlogModule("xilinxcorelib_ver","BLK_MEM_GEN_V2_4", (HSimInstFactoryPtr)IF2);
        (*cfgvh).addVlogModule("xilinxcorelib_ver","BLK_MEM_GEN_V2_4", (HSimInstFactoryPtr)IF3);
        (*cfgvh).addVlogModule("xilinxcorelib_ver","BLK_MEM_GEN_V2_4", (HSimInstFactoryPtr)IF4);
        (*cfgvh).addVlogModule("work","AutoCorr_mem_1", (HSimInstFactoryPtr)IF5);
        (*cfgvh).addVlogModule("work","LPC_Mem_Ctrl", (HSimInstFactoryPtr)IF6);
        (*cfgvh).addVlogModule("work","glbl", (HSimInstFactoryPtr)IF7);
        HSim__s5 * topvl = 0;
        extern HSim__s6 * createworkM_l_p_c___mem___ctrl__tb__v(const char*);
        topvl = (HSim__s5*)createworkM_l_p_c___mem___ctrl__tb__v("LPC_Mem_Ctrl_tb_v");
        topvl->moduleInstantiate(cfgvh);
        addChild(topvl);
        extern HSim__s6 * createworkMglbl(const char*);
        topvl = (HSim__s5*)createworkMglbl("glbl");
        topvl->moduleInstantiate(cfgvh);
        addChild(topvl);
        return cfgvh;
}
};

main(int argc, char **argv) {
  HSimDesign::initDesign();
  globalKernel->getOptions(argc,argv);
  HSim__s6 * _top_i = 0;
  try {
    HSimConfigDecl *cfg;
 _top_i = new _top();
  cfg =  _top_i->topModuleInstantiate();
    return globalKernel->runTcl(cfg, _top_i, "_top", argc, argv);
  }
  catch (HSimError& msg){
    try {
      globalKernel->error(msg.ErrMsg);
      return 1;
    }
    catch(...) {}
      return 1;
  }
  catch (...){
    globalKernel->fatalError();
    return 1;
  }
}
