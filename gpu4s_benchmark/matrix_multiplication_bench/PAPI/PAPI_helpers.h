#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include "/home/antonio/Documents/PerFI_PAPI_wd/PAPI/papi/src/install/include/papi.h"
#include "/home/antonio/Documents/PerFI_PAPI_wd/PAPI/papi/src/testlib/papi_test.h"

#define PRINT(quiet, format, args...) {if (!quiet) {fprintf(stderr, format, ## args);}}

//expect to pass the address of the normal char **argv and int argc found in the main function (so, &argv and &argc) in each of the two below functions
void PAPI_pre(int ,char ** ); //change to local variables, I.T.
void PAPI_post(int ,char ** );
void printFrstChars (char inp[], int len);


int papi_errno;
int EventSet;
long long *values;
int ones;
int tens;
int hundreds;
int eventCount=-1;
int quiet;
CUcontext getCtx, sessionCtx;
CUresult cuError;

void printFrstChars (char inp[], int len)
{
	for(int i = 0; inp[i] != '\0' && i < len; i++){
		printf("%c", inp[i]);
	}
	printf("\n");
}

void read_now(int myargc,char ** myargv){
	papi_errno = PAPI_read( EventSet, values );
        if( papi_errno != PAPI_OK ) {
                test_fail(__FILE__, __LINE__, "PAPI_read failed", papi_errno);
        }
	for( int i = 0; i < eventCount; i++ )
		PRINT( quiet, "read: %12lld \t=0X%016llX \t\t --> %s \n", values[i], values[i], myargv[myargc-eventCount+i]);
}
