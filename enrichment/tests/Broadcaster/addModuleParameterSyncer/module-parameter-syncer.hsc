// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "SyncGain"
/exit

/script
/callback onInit
// end setup
// Title: Syncing a broadcaster value to a module parameter
const var bc = Engine.createBroadcaster({
    "id": "GainSync",
    "args": ["processorId", "parameterId", "value"]
});

bc.addModuleParameterSyncer("SyncGain", "Gain", "gainTarget");
bc.sendSyncMessage(["SyncGain", "Gain", -12.0]);

const var gain = Synth.getEffect("SyncGain");
// test
/compile

# Verify
/expect gain.getAttribute(gain.Gain) is -12.0
/exit
// end test
