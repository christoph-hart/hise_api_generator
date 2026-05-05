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
const var th0 = Engine.createTransportHandler();
th0.setSyncMode(th0.InternalOnly);
th0.stopInternalClock(0);

const var th = Engine.createTransportHandler();

var transportLog = [];

inline function onTransportChanged(isPlaying)
{
    transportLog.push(isPlaying);
}

th.setOnTransportChange(SyncNotification, onTransportChanged);

// Trigger a transport change programmatically
th.startInternalClock(0);
// test
/compile

# Verify
/expect transportLog.length is 2
/expect transportLog[0] is false
/expect transportLog[1] is true
/exit
// end test
