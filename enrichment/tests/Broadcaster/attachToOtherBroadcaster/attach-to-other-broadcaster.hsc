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
// Title: Chaining broadcasters with argument transformation
const var source = Engine.createBroadcaster({
    "id": "Source",
    "args": ["x", "y"]
});

const var target = Engine.createBroadcaster({
    "id": "Target",
    "args": ["sum"]
});

var log = [];

target.addListener("logger", "sumLog", function(sum)
{
    log.push(sum);
});

inline function transformArgs(x, y)
{
    return [x + y];
}

target.attachToOtherBroadcaster(source, transformArgs, false, "chainSource");
source.sendSyncMessage([3, 4]);
source.sendSyncMessage([10, 20]);
// test
/compile

# Verify
/expect log.length is 3
/expect log[1] is 7
/expect log[2] is 30
/exit
// end test
