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
Engine.setHostBpm(120);

const var th = Engine.createTransportHandler();

// Enable a 1/16 note grid
th.setEnableGrid(true, 11);

// Enable a 1/8 note grid (overwrites the previous)
th.setEnableGrid(true, 8);
// test
/compile

# Verify
/expect th.getGridLengthInSamples() is 11025
/exit
// end test
