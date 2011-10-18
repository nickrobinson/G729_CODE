/* ITU-T G.729 Software Package Release 2 (November 2006) */
/* ITU-T G.729 - Reference C code for fixed point implementation */
/* Version 3.3    Last modified: December 26, 1995 */

/*-------------------------------------------------------------------*
 * Function  Convolve:                                               *
 *           ~~~~~~~~~                                               *
 *-------------------------------------------------------------------*
 * Perform the convolution between two vectors x[] and h[] and       *
 * write the result in the vector y[].                               *
 * All vectors are of length N.                                      *
 *-------------------------------------------------------------------*/

#include "typedef.h"
#include "basic_op.h"
#include "ld8k.h"
#include <stdio.h>
//FILE *CONVOLVE; 	//(Zach's print files)
void Convolve(
  Word16 x[],      /* (i)     : input vector                           */
  Word16 h[],      /* (i) Q12 : impulse response                       */
  Word16 y[],      /* (o)     : output vector                          */
  Word16 L         /* (i)     : vector size                            */
)
{
   Word16 i, n;
   Word32 s;
   //CONVOLVE = fopen("A_convolve.out", "a");	 //(Zach's residu 							    print files)
   for (n = 0; n < L; n++)
   {
     s = 0;
     for (i = 0; i <= n; i++)
     {
	//fprintf(CONVOLVE,"L_macA[%d]: %x\n",40*n+i,x[i]);  //(Zach's print files)
	//fprintf(CONVOLVE,"L_macB[%d]: %x\n",40*n+i,h[n-i]);  //(Zach's print files) 
	//fprintf(CONVOLVE,"L_macC[%d]: %x\n",40*n+i,s);  //(Zach's print files)        
	s = L_mac(s, x[i], h[n-i]);
	//fprintf(CONVOLVE,"L_macIn[%d]: %x\n",40*n+i,s);  //(Zach's print files) 
     }
     //fprintf(CONVOLVE,"L_shlOut[%d]: %x\n",n,s);  //(Zach's print files) 
     s    = L_shl(s, 3);                   /* h is in Q12 and saturation */
     //fprintf(CONVOLVE,"L_shlIn[%d]: %x\n",n,s);  //(Zach's print files) 
     y[n] = extract_h(s);
     //fprintf(CONVOLVE,"y[%d]: %x\n",n,y[n]);  //(Zach's print files) 
   }
   //fprintf(CONVOLVE,"\n");  //(Zach's print files) 
   //fclose(CONVOLVE);		//(Zach's residu print files)
   return;
}

/*-----------------------------------------------------*
 * procedure Syn_filt:                                 *
 *           ~~~~~~~~                                  *
 * Do the synthesis filtering 1/A(z).                  *
 *-----------------------------------------------------*/


void Syn_filt(
  Word16 a[],     /* (i) Q12 : a[m+1] prediction coefficients   (m=10)  */
  Word16 x[],     /* (i)     : input signal                             */
  Word16 y[],     /* (o)     : output signal                            */
  Word16 lg,      /* (i)     : size of filtering                        */
  Word16 mem[],   /* (i/o)   : memory associated with this filtering.   */
  Word16 update   /* (i)     : 0=no update, 1=update of memory.         */
)
{
  Word16 i, j;
  Word32 s;
  Word16 tmp[80];     /* This is usually done by memory allocation (lg+M) */
  Word16 *yy;

  /* Copy mem[] to yy[] */

  yy = tmp;

  for(i=0; i<M; i++)
  {
    *yy++ = mem[i];
  }

  /* Do the filtering. */

  for (i = 0; i < lg; i++)
  {
    s = L_mult(x[i], a[0]);
    for (j = 1; j <= M; j++)
      s = L_msu(s, a[j], yy[-j]);

    s = L_shl(s, 3);
    *yy++ = round(s);
  }

  for(i=0; i<lg; i++)
  {
    y[i] = tmp[i+M];
  }

  /* Update of memory if update==1 */

  if(update != 0)
     for (i = 0; i < M; i++)
     {
       mem[i] = y[lg-M+i];
     }

 return;
}

/*-----------------------------------------------------------------------*
 * procedure Residu:                                                     *
 *           ~~~~~~                                                      *
 * Compute the LPC residual  by filtering the input speech through A(z)  *
 *-----------------------------------------------------------------------*/
/*FILE *RESIDU_A_IN; 	//(Zach's Residu print files)
FILE *RESIDU_X_IN; 	//(Zach's Residu print files)
FILE *RESIDU_Y_OUT; 	//(Zach's Residu print files)
FILE *RESIDU_TEST; 	//(Zach's Residu print files)*/

void Residu(
  Word16 a[],    /* (i) Q12 : prediction coefficients                     */
  Word16 x[],    /* (i)     : speech (values x[-m..-1] are needed         */
  Word16 y[],    /* (o)     : residual signal                             */
  Word16 lg      /* (i)     : size of filtering                           */
)
{
  Word16 i, j;
  Word32 s;

  /*RESIDU_A_IN = fopen("A_residu_a_in.out", "a");	 //(Zach's print files)
  RESIDU_X_IN = fopen("A_residu_x_in.out", "a");	 //(Zach's print files)
  RESIDU_Y_OUT = fopen("A_residu_y_out.out", "a");	 //(Zach's print files)
  RESIDU_TEST = fopen("A_residu_test.out", "a");	 //(Zach's print files)

  for(i= 0;i<=M;i++)
	fprintf(RESIDU_A_IN,"A[%d]: %x\n",i,a[i]);  //(Zach's print files)
  for(i=-10;i<40;i++)
  	fprintf(RESIDU_X_IN,"X[%d]: %x\n",i,x[i]);  //(Zach's print files)
  fprintf(RESIDU_A_IN,"\n");  //(Zach's print files)
  fprintf(RESIDU_X_IN,"\n");  //(Zach's print files)*/

  for (i = 0; i < lg; i++)
  {
    /*fprintf(RESIDU_TEST,"i = %d ",i);  //(Zach's print files)
    fprintf(RESIDU_TEST,"i = %d ",i);  //(Zach's print files)
    fprintf(RESIDU_TEST,"i = %d ",i);  //(Zach's print files)
    fprintf(RESIDU_TEST,"i = %d ",i);  //(Zach's print files)
    fprintf(RESIDU_TEST,"i = %d ",i);  //(Zach's print files)
    fprintf(RESIDU_TEST,"i = %d ",i);  //(Zach's print files)
    fprintf(RESIDU_TEST,"i = %d\n",i);  //(Zach's print files)
    fprintf(RESIDU_TEST,"L_multOutA: %x\n",x[i]);  //(Zach's print files)
    fprintf(RESIDU_TEST,"L_multOutB: %x\n",a[0]);  //(Zach's print files)*/
    s = L_mult(x[i], a[0]);
    //fprintf(RESIDU_TEST,"L_multIn: %x\n\n",s);  //(Zach's print files)
    for (j = 1; j <= M; j++)
    {
	/*fprintf(RESIDU_TEST,"j = %x\n",j);  //(Zach's print files)
	fprintf(RESIDU_TEST,"L_macOutA: %x\n",a[j]);  //(Zach's print files)
	fprintf(RESIDU_TEST,"L_macOutB: %x\n",x[i-j]);  //(Zach's print files)
	fprintf(RESIDU_TEST,"L_macOutC: %x\n",s);  //(Zach's print files)*/      
	s = L_mac(s, a[j], x[i-j]);
        //fprintf(RESIDU_TEST,"L_macIn: %x\n",s);  //(Zach's print files)      
        //fprintf(RESIDU_TEST,"x[%d]: %x\n",i-j,x[i-j]);  //(Zach's perc_var print files)
    }
    /*fprintf(RESIDU_TEST,"\n");  //(Zach's perc_var print files)
    fprintf(RESIDU_TEST,"L_shlVar1: %x\n",s);  //(Zach's print files)
    fprintf(RESIDU_TEST,"L_shlNumShift: %x\n",3);  //(Zach's print files)*/	
    s = L_shl(s, 3);
    //fprintf(RESIDU_TEST,"L_shlIn: %x\n",s);  //(Zach's print files)
    y[i] = round(s);
    //fprintf(RESIDU_TEST,"roundIn: %x\n\n",y[i]);  //(Zach's print files)
    //fprintf(RESIDU_Y_OUT,"%x\n",y[i]);  //(Zach's print files)
  }
  /*fprintf(RESIDU_TEST,"END END END END END END END \n\n\n");  //(Zach's perc_var print files)	
  fclose(RESIDU_A_IN);		//(Zach's print files)
  fclose(RESIDU_X_IN);		//(Zach's print files)
  fclose(RESIDU_Y_OUT);		//(Zach's print files)
  fclose(RESIDU_TEST);	//(Zach's print files)*/
  return;
}
