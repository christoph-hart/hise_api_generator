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
const var bc = Engine.createBroadcaster({
    "id": "BypassTest",
    "args": ["value"]
});

var received = [];

bc.addListener("logger", "Tracks values",
function(value)
{
    received.push(value);
});

bc.sendSyncMessage([10]);
bc.setBypassed(true, false, false);
bc.sendSyncMessage([20]);
bc.sendSyncMessage([30]);
bc.setBypassed(false, true, true);
// test
/compile

# Verify
/expect received.length is 2
/expect received[0] is 10
/expect received[1] is 30
/exit
// end test
