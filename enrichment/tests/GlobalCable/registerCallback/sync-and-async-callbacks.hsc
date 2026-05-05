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
// Register both sync and async callbacks
const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("MyCable");

cable.setRange(0.0, 1.0);

// Async callback (safe, runs on UI thread)
inline function onCableAsync(value)
{
    Console.print("Async: " + value);
};

cable.registerCallback(onCableAsync, AsyncNotification);

// Sync callback (runs on calling thread, must be realtime-safe)
inline function onCableSync(value)
{
    // Only do realtime-safe operations here
};

cable.registerCallback(onCableSync, SyncNotification);
// test
reg syncResult = -1.0;
inline function testSyncCapture(v) { syncResult = v; };
cable.registerCallback(testSyncCapture, SyncNotification);
cable.setValue(0.5);
/compile

# Verify
/expect syncResult is 0.5
/exit
// end test
