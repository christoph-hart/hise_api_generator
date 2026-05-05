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
// Title: Argument transformation between broadcasters
// Context: When chaining broadcasters with different argument structures,
// use the transform function to reshape the data.

const var source = Engine.createBroadcaster({
    "id": "KnobPair",
    "args": ["component", "value"]
});

const var target = Engine.createBroadcaster({
    "id": "ScaledValue",
    "args": ["scaledValue"]
});

var scaledLog = [];

// Transform 2 args (component, value) into 1 arg (scaled value)
inline function scaleValue(component, value)
{
    return [value * 100.0];
}

target.attachToOtherBroadcaster(source, scaleValue, false, "scale");

target.addListener("", "display", function(scaledValue)
{
    scaledLog.push(scaledValue);
});
// test
source.sendSyncMessage(["test", 0.75]);
/compile

# Verify
/expect scaledLog[scaledLog.length - 1] is 75.0
/exit
// end test
