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
    "id": "StatusBC",
    "args": ["status", "count"]
});

var log = [];

inline function onStatus(status, count)
{
    log.push(status + ":" + count);
}

bc.addListener("handler", "statusLogger", onStatus);
bc.sendSyncMessage(["ready", 1]);
bc.sendSyncMessage(["done", 2]);
// test
/compile

# Verify
/expect log.length is 2
/expect log[0] is "ready:1"
/expect log[1] is "done:2"
/exit
// end test
