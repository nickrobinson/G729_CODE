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

#ifndef H_xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4_H
#define H_xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4_H

#ifdef _MSC_VER
#pragma warning(disable: 4355)
#endif

#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif

class xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4 : public HSim__s5{
public: 
    xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4(const char *instname);
    ~xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4();
    void setDefparam();
    void constructObject();
    void moduleInstantiate(HSimConfigDecl *cfg);
    void connectSigs();
    void reset();
    virtual void archImplement();
    HSim::ValueS* up47Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up48Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up49Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up50Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up51Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up52Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up53Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up54Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up55Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up56Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up57Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up58Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up59Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up60Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up61Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up62Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up63Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up64Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up66Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up67Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up68Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up69Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up70Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up71Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up72Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    HSim::ValueS* up73Func(HSim::VlogVarType& outVarType, int& outNumScalars, int inNumScalars);
    void paramAssign();
    class cu4 : public HSimVlogTask{
    public: 
        HSim__s3 uv[6];
        cu4(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch );
        HSimVlogTaskCall * createTaskCall(HSim__s7 * process );
        void deleteTaskCall(HSimVlogTaskCall *p );
        void reset();
        void constructObject();
        int getSizeForArg(int argNumber);
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch ;
        HSimVector<HSimRegion *> activeInstanceList ;
        HSimVector<HSimRegion *>  availableTaskCallObjList ;
        ~cu4();
        bool disable(HSim__s7* proc);
    };
    cu4 u12;
    class cu5 : public HSimVlogTask{
    public: 
        HSim__s3 uv[6];
        cu5(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch );
        HSimVlogTaskCall * createTaskCall(HSim__s7 * process );
        void deleteTaskCall(HSimVlogTaskCall *p );
        void reset();
        void constructObject();
        int getSizeForArg(int argNumber);
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch ;
        HSimVector<HSimRegion *> activeInstanceList ;
        HSimVector<HSimRegion *>  availableTaskCallObjList ;
        ~cu5();
        bool disable(HSim__s7* proc);
    };
    cu5 u13;
    class cu6 : public HSimVlogTask{
    public: 
        HSim__s3 uv[4];
        cu6(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch );
        HSimVlogTaskCall * createTaskCall(HSim__s7 * process );
        void deleteTaskCall(HSimVlogTaskCall *p );
        void reset();
        void constructObject();
        int getSizeForArg(int argNumber);
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch ;
        HSimVector<HSimRegion *> activeInstanceList ;
        HSimVector<HSimRegion *>  availableTaskCallObjList ;
        ~cu6();
        bool disable(HSim__s7* proc);
    };
    cu6 u14;
    class cu7 : public HSimVlogTask{
    public: 
        HSim__s3 uv[4];
        cu7(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch );
        HSimVlogTaskCall * createTaskCall(HSim__s7 * process );
        void deleteTaskCall(HSimVlogTaskCall *p );
        void reset();
        void constructObject();
        int getSizeForArg(int argNumber);
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch ;
        HSimVector<HSimRegion *> activeInstanceList ;
        HSimVector<HSimRegion *>  availableTaskCallObjList ;
        ~cu7();
        bool disable(HSim__s7* proc);
    };
    cu7 u15;
    class cu8 : public HSimVlogTask{
    public: 
        HSim__s3 uv[4];
        cu8(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch );
        HSimVlogTaskCall * createTaskCall(HSim__s7 * process );
        void deleteTaskCall(HSimVlogTaskCall *p );
        void reset();
        void constructObject();
        int getSizeForArg(int argNumber);
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch ;
        HSimVector<HSimRegion *> activeInstanceList ;
        HSimVector<HSimRegion *>  availableTaskCallObjList ;
        ~cu8();
        bool disable(HSim__s7* proc);
    };
    cu8 u16;
    class cu9 : public HSimVlogTask{
    public: 
        HSim__s3 uv[4];
        cu9(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch );
        HSimVlogTaskCall * createTaskCall(HSim__s7 * process );
        void deleteTaskCall(HSimVlogTaskCall *p );
        void reset();
        void constructObject();
        int getSizeForArg(int argNumber);
        int getSize();
        HSim::VlogVarType getType();
        int constructObjectCalled;
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch ;
        HSimVector<HSimRegion *> activeInstanceList ;
        HSimVector<HSimRegion *>  availableTaskCallObjList ;
        ~cu9();
        bool disable(HSim__s7* proc);
    };
    cu9 u17;
    class cu10 : public HSimVlogTask{
    public: 
        HSim__s3 uv[20];
        cu10(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch );
        HSimVlogTaskCall * createTaskCall(HSim__s7 * process );
        void deleteTaskCall(HSimVlogTaskCall *p );
        void reset();
        void constructObject();
        int getSizeForArg(int argNumber);
        int getSize();
        HSim::VlogVarType getType();
        int constructObjectCalled;
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch ;
        HSimVector<HSimRegion *> activeInstanceList ;
        HSimVector<HSimRegion *>  availableTaskCallObjList ;
        ~cu10();
        bool disable(HSim__s7* proc);
    };
    cu10 u18;
    void genModuleInstantiate(HSimConfigDecl *cfg);
    void genParamAssign();
    void genSetDefparam();
    void genParamValue(HSimConfigDecl *cfg);
    class cu0 : public HSim__s6 {
    public:
        cu0(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch);
        ~cu0();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch;
    };
    cu0* u0;
    class cu1 : public HSim__s6 {
    public:
        cu1(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch);
        ~cu1();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch;
    };
    cu1* u1;
    class cu2 : public HSim__s6 {
    public:
        cu2(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch);
        ~cu2();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch;
    };
    cu2* u2;
    class cu3 : public HSim__s6 {
    public:
        cu3(xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* arch);
        ~cu3();
        void constructObject();
        void moduleInstantiate(HSimConfigDecl *cfg);
        void setDefparam();
        void archImplement();
        void connectSigs();
        HSim__s1 us[6];
        xilinxcorelib_ver_auxlibM_b_l_k___m_e_m___g_e_n___v2__4* Arch;
    };
    cu3* u3;
    HSim__s1 us[26];
    HSim__s3 uv[18];
    HSimVlogParam up[74];
};

#endif
