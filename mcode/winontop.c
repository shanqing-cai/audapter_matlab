/* winontop.c
 * set "topmost" state of figure window 
 */
 
 #include <windows.h>
 #include <string.h>
 #include <shellapi.h>
 #include "mex.h"
 #include "matrix.h"

 void mexFunction( int nlhs, mxArray *plhs[], int nrhs, 
    const mxArray *prhs[]) 
 {

  char *windowName, n = 1;
  short int figureHandle;
  HWND hwnd;
  RECT rectWin;

  /* check for proper number of input arguments */
  if( !(nrhs > 0) || !(nrhs < 3) || !(nlhs == 0) )
    mexErrMsgIdAndTxt("MATLAB:winontop",
      "Improper number of input or output arguments");
  
  /* first input argument: figure handle */
  figureHandle = (short int)mxGetScalar(prhs[0]);
  windowName = mxCalloc(1,sizeof(figureHandle)+8);
  sprintf(windowName,"Figure %d",figureHandle);
  
  /* check that first input argument is a valid figure handle */
  if( mexGet(figureHandle,"Visible") == NULL )
    mexErrMsgIdAndTxt("MATLAB:winontop",
      "First input argument must be a figure handle");
  
  /* second input argument: changes 'topmost' property */
  if( nrhs == 2 )
    n = (char)mxGetScalar(prhs[1]);
  
  /* check that second input argument is valid */
  if( !( (n == 1) || (n == 0) ) )
    mexErrMsgIdAndTxt("MATLAB:winontop",
      "Second input argument must be 0 or 1");

  /* set state of topmost property */
 	if (hwnd = FindWindow(NULL,windowName)) {
        
        // get window position
        GetWindowRect(hwnd, &rectWin); 
        
  	if( n == 1 )
      SetWindowPos(hwnd,HWND_TOPMOST,rectWin.left,rectWin.top,0,0,SWP_NOSIZE);
  	else
      SetWindowPos(hwnd,HWND_NOTOPMOST,rectWin.left,rectWin.top,0,0,SWP_NOSIZE);
	}
}
