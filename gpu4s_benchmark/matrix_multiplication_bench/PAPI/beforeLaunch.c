//#include "PAPI_helpers.h"

void PAPI_pre(int myargc,char **myargv){
	char *test_quiet = getenv("PAPI_CUDA_TEST_QUIET");
    if (test_quiet)
        quiet = (int) strtol(test_quiet, (char**) NULL, 10);

	/* PAPI Initialization */
	papi_errno = PAPI_library_init( PAPI_VER_CURRENT );
	if( papi_errno != PAPI_VER_CURRENT ) {
		test_fail(__FILE__,__LINE__, "PAPI_library_init failed", 0 );
	}
	
	/*printf( "PAPI_VERSION     : %4d %6d %7d\n",
		PAPI_VERSION_MAJOR( PAPI_VERSION ),
		PAPI_VERSION_MINOR( PAPI_VERSION ),
		PAPI_VERSION_REVISION( PAPI_VERSION ) );
	*/

	int i;
	EventSet = PAPI_NULL;
	switch(strlen(myargv[1])){
		case 1 : eventCount=((int) myargv[1][0])-48; break;//printf("in event 1"); break;
		case 2 : ones =((int) myargv[1][1])-48; tens=((int) myargv[1][0])-48; eventCount=ones+(tens*10); break;//printf("in event 2"); break;
		case 3 : ones =((int) myargv[1][2])-48; tens=((int) myargv[1][1])-48; hundreds=((int) myargv[1][0])-48; eventCount=ones+(tens*10)+(hundreds*100); break;
		default : printf("ERROR: Invalid eventCountabove, strlength: %lu",strlen(myargv[1])); break;
	}
	//printf("eventCount: %i",eventCount); 
	//printf("eventCount: %i",myargc-eventCount+0);//eventCount);
	//printFrstChars(myargv[4],10);
//	printFrstChars(myargv[(myargc-((int)myargv[1][0])-48)+0],10);
	/* if no events passed at command line, just report test skipped. */
	if ((eventCount == -1)||(eventCount == 0)) {
		fprintf(stderr, "No eventnames specified at command line.");
		test_skip(__FILE__, __LINE__, "", 0);
	}
	//printf("\nherrer\n");
	values = (long long *) calloc(eventCount, sizeof (long long));
    if (values == NULL) {
        test_fail(__FILE__, __LINE__, "Failed to allocate memory for values.\n", 0);
    }
	int *myevents = (int *) calloc(eventCount, sizeof (int));
    if (myevents == NULL) {
        test_fail(__FILE__, __LINE__, "Failed to allocate memory for events.\n", 0);
    }
	/* convert PAPI native events to PAPI code */
	for( i = 0; i < eventCount; i++ ){
        //printf("about to convert name to code");
	papi_errno = PAPI_event_name_to_code( myargv[myargc-eventCount+i], &myevents[i] );
	//	printf("after call");
		if( papi_errno != PAPI_OK ) {
			//printf("papi_errno: %i",papi_errno);
			char *a =PAPI_strerror(papi_errno);
			printFrstChars(a,30);
			fprintf(stderr, "Check event name: %s", myargv[myargc-eventCount+i] );
			test_skip(__FILE__, __LINE__, "", 0);
		}
        PRINT( quiet, "Name %s --- Code: %#x\n", myargv[myargc-eventCount+i], myevents[i] );
	}

	papi_errno = PAPI_create_eventset( &EventSet );
	if( papi_errno != PAPI_OK ) {
		test_fail(__FILE__,__LINE__,"Cannot create eventset",papi_errno);
	}

    // Context Create. We will use this one to run our kernel.
    cuError = cuCtxCreate(&sessionCtx, 0, 0); // Create a context, NULL flags, Device 0.
    if (cuError != CUDA_SUCCESS) {
        fprintf(stderr, "Failed to create cuContext.\n");
        exit(-1);
    }
    
    papi_errno = PAPI_add_events( EventSet, myevents, eventCount );
    if (papi_errno == PAPI_ENOEVNT) {
        fprintf(stderr, "Event name does not exist for component.");
        test_skip(__FILE__, __LINE__, "", 0);
    }
	if( papi_errno != PAPI_OK ) {
		test_fail(__FILE__, __LINE__, "PAPI_add_events failed", papi_errno);
	}
    //printf("\nhere-3\n");
    
   
    papi_errno = PAPI_reset( EventSet );
        if( papi_errno != PAPI_OK ) {
        test_fail(__FILE__, __LINE__, "PAPI_reset failed.", papi_errno);
        }

    papi_errno = PAPI_start( EventSet );
	if( papi_errno != PAPI_OK ) {
        test_fail(__FILE__, __LINE__, "PAPI_start failed.", papi_errno);
	}

    fprintf(stderr,"\nBefore launch\n"); 
    read_now(myargc,myargv);
}
