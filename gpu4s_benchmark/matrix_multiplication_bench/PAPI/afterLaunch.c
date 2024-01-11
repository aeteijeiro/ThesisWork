//#include "PAPI_helpers.h"

void PAPI_post(int myargc,char **myargv){
    
    fprintf(stderr,"\nAfter launch:\n");
    //read_now(myargc,myargv);
    papi_errno = cuCtxPopCurrent(&getCtx);
	if( papi_errno != CUDA_SUCCESS) {
		fprintf( stderr, "cuCtxPopCurrent failed, papi_errno=%d (%s)\n", papi_errno, PAPI_strerror(papi_errno) );
        exit(1);
    }

	papi_errno = PAPI_stop( EventSet, values );
	if( papi_errno != PAPI_OK ) {
		test_fail(__FILE__, __LINE__, "PAPI_stop failed", papi_errno);
    }


	papi_errno = PAPI_cleanup_eventset(EventSet);
	if( papi_errno != PAPI_OK ) {
		test_fail(__FILE__, __LINE__, "PAPI_cleanup_eventset failed", papi_errno);
    }


	papi_errno = PAPI_destroy_eventset(&EventSet);
	if (papi_errno != PAPI_OK) {
		test_fail(__FILE__, __LINE__, "PAPI_destroy_eventset failed", papi_errno);
    }



	for( int i = 0; i < eventCount; i++ )
		PRINT( quiet, "stop: %12lld \t=0X%016llX \t\t --> %s \n", values[i], values[i], myargv[myargc-eventCount+i]);

     // Test destroying the session Context.
    if (sessionCtx != NULL) {
        cuCtxDestroy(sessionCtx);
    }

	PAPI_shutdown();

	//test_pass(__FILE__);
}
