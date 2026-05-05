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
    "id": "StatusBc",
    "args": ["status", "count"]
});

var lastStatus = "";
var lastCount = 0;

bc.addListener("logger", "Captures status",
function(status, count)
{
    lastStatus = status;
    lastCount = count;
});

bc.sendSyncMessage(["active", 5]);
// test
/compile

# Verify
/expect lastStatus is "active"
/expect lastCount is 5
/expect bc.status is "active"
/expect bc.count is 5
/exit
// end test
