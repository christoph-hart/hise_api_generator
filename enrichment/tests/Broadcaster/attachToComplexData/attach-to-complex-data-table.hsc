// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SineSynth as MySynth
add Velocity to MySynth.gain as "WatchTable"
/exit

/script
/callback onInit
// end setup
// Title: Watching a table's content changes
const var bc = Engine.createBroadcaster({
    "id": "TableWatch",
    "args": ["processorId", "index", "value"]
});

var lastProcId = "";
var lastIndex = -1;

inline function onTableChange(processorId, index, value)
{
    lastProcId = processorId;
    lastIndex = index;
}

bc.addListener("handler", "tableLogger", onTableChange);
bc.attachToComplexData("Table.Content", "WatchTable", 0, "tableSource");
// test
/compile

# Verify
/expect lastProcId is "WatchTable"
/expect lastIndex is 0
/exit
// end test
