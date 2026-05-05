// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "WatchGain"
/exit

/script
/callback onInit
// end setup
const var bc = Engine.createBroadcaster({
    "id": "ParamWatch",
    "args": ["processorId", "parameterId", "value"]
});

var lastParamId = "";
var lastParamValue = -1.0;

inline function onParamChange(processorId, parameterId, value)
{
    lastParamId = parameterId;
    lastParamValue = value;
}

bc.addListener("handler", "paramLogger", onParamChange);
bc.attachToModuleParameter("WatchGain", ["Gain"], "paramSource");

const var gain = Synth.getEffect("WatchGain");
// test
/compile

# Verify
/expect lastParamId is "Gain"
/expect lastParamValue is 0.0
/exit
// end test
