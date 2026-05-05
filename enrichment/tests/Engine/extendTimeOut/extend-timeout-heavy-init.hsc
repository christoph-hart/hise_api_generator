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
// Title: Extending timeout during heavy initialization
// Context: Plugins with large sample libraries or complex Builder
// API setups need to extend the compilation timeout to prevent
// HISE from aborting the initialization. Call this before or
// during the long-running operation.

// Extend by 10 seconds before a heavy initialization loop
Engine.extendTimeOut(10000);

// ... heavy initialization code (Builder API, sample loading, etc.)

// Can be called multiple times if needed
Engine.extendTimeOut(5000);
// test
/compile

# Verify
/expect Engine.getUptime() >= 0 is true
/exit
// end test
