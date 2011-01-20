////////////////////////////////////////////////////////////////////////////////
//   ____  ____  
//  /   /\/   /  
// /___/  \  /   
// \   \   \/    
//  \   \        Copyright (c) 2003-2004 Xilinx, Inc.
//  /   /        All Right Reserved. 
// /___/   /\   
// \   \  /  \  
//  \___\/\___\ 
////////////////////////////////////////////////////////////////////////////////

#ifndef H_xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage_H
#define H_xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage_H

#ifdef _MSC_VER
#pragma warning(disable: 4355)
#endif

#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif

class xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage : public HSim__s5{
public: 
    xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage(const char *instname);
    ~xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage();
    void setDefparam();
    void constructObject();
    void moduleInstantiate(HSimConfigDecl *cfg);
    void connectSigs();
    void reset();
    virtual void archImplement();
    HSim::ValueS* up11Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    void genModuleInstantiate(HSimConfigDecl *cfg);
    void genParamAssign();
    void genSetDefparam();
    void genParamValue(HSimConfigDecl *cfg);
    class cu0 : public HSim__s6 {
    public:
        cu0(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* arch);
        ~cu0();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* Arch;
    };
    cu0* u0;
    class cu1 : public HSim__s6 {
    public:
        cu1(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* arch);
        ~cu1();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* Arch;
    };
    cu1* u1;
    class cu2 : public HSim__s6 {
    public:
        cu2(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* arch);
        ~cu2();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* Arch;
    };
    cu2* u2;
    class cu3 : public HSim__s6 {
    public:
        cu3(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* arch);
        ~cu3();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4__output__stage* Arch;
    };
    cu3* u3;
    HSim__s2 *driver_us0;
    HSim__s1 us[9];
    HSim__s3 uv[3];
    HSimVlogParam up[12];
};

#endif
