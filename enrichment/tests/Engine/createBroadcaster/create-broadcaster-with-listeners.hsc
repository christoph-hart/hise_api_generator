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
    "id": "ValueBroadcaster",
    "args": ["value", "source"]
});

var lastValue = 0;

bc.addListener("logger", "Tracks value changes",
function(value, source)
{
    lastValue = value;
});

bc.sendSyncMessage([42, "knob"]);
// test
/compile

# Verify
/expect lastValue is 42
/expect bc.value is 42
/expect bc.source is "knob"
/exit
// end test
