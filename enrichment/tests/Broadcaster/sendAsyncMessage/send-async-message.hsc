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
// Title: Broadcasting values asynchronously
const var bc = Engine.createBroadcaster({
    "id": "StatusBroadcaster",
    "args": ["status", "count"]
});

var lastStatus = "";

inline function onStatusChange(status, count)
{
    lastStatus = status;
}

bc.addListener("handler", "statusLogger", onStatusChange);
bc.sendAsyncMessage(["ready", 1]);
// test
/compile

# Verify
/wait 300ms
/expect lastStatus is "ready"
/exit
// end test
