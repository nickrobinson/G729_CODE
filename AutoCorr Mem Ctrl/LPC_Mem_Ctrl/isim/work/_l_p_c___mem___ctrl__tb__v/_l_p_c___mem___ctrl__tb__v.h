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

#ifndef H_workM_l_p_c___mem___ctrl__tb__v_H
#define H_workM_l_p_c___mem___ctrl__tb__v_H

#ifdef _MSC_VER
#pragma warning(disable: 4355)
#endif

#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif

class workM_l_p_c___mem___ctrl__tb__v : public HSim__s5{
public: 
    workM_l_p_c___mem___ctrl__tb__v(const char *instname);
    ~workM_l_p_c___mem___ctrl__tb__v();
    void setDefparam();
    void constructObject();
    void moduleInstantiate(HSimConfigDecl *cfg);
    void connectSigs();
    void reset();
    virtual void archImplement();
    HSim__s1 us[2];
    HSim__s3 uv[9];
};

#endif
