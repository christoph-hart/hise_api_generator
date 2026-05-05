// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add StreamingSampler as "Sampler1"
/exit

/script
/callback onInit
// end setup
const var bc = Engine.createBroadcaster({
    "id": "SampleMapWatch",
    "args": ["eventType", "samplerId", "data"]
});

var eventLog = [];

bc.addListener("logger", "smLog", function(eventType, samplerId, data)
{
    eventLog.push(eventType + ":" + samplerId);
});

bc.attachToSampleMap("Sampler1", ["SampleMapChanged", "SamplesAddedOrRemoved"], "smSource");
// test
/compile

# Verify
/expect eventLog.length is 2
/exit
// end test
