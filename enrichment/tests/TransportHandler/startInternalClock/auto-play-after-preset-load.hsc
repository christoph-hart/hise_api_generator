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
// Title: Auto-play after preset load with grid resync
const var th0 = Engine.createTransportHandler();
th0.setSyncMode(th0.InternalOnly);
th0.stopInternalClock(0);
Engine.setHostBpm(120);

// Context: When loading a new preset while playback was active, the clock must be
// stopped before load and restarted after. sendGridSyncOnNextCallback() ensures the
// grid restarts cleanly instead of continuing from a stale position.
const var th = Engine.createTransportHandler();
th.setEnableGrid(true, 8);

// Before preset load: stop the clock
th.stopInternalClock(0);

// After preset load completes: resync and restart
th.sendGridSyncOnNextCallback();
th.startInternalClock(0);
// test
/compile

# Verify
/expect th.isPlaying() is true
/exit
// end test
