// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

/script
/callback onInit
// end setup
// Title: Registering a custom error callback
const var eh = Engine.createErrorHandler();

reg lastState = -1;

inline function onError(state, message)
{
    lastState = state;
};

eh.setErrorCallback(onError);
// test
eh.simulateErrorEvent(eh.IllegalBufferSize);
/compile

# Verify
/expect lastState is 11
/exit
// end test
