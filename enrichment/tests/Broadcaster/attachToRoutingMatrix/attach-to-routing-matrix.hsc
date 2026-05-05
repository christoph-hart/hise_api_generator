// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "SimpleGain1"
/exit

/script
/callback onInit
// end setup
// Title: Monitoring routing matrix changes on a processor
const var bc = Engine.createBroadcaster({
    "id": "MatrixWatch",
    "args": ["processorId", "matrix"]
});

var lastProcessorId = "";

bc.addListener("handler", "matrixHandler", function(processorId, matrix)
{
    lastProcessorId = processorId;
});

bc.attachToRoutingMatrix("SimpleGain1", "matrixSource");
// test
/compile

# Verify
/expect lastProcessorId is "SimpleGain1"
/exit
// end test
