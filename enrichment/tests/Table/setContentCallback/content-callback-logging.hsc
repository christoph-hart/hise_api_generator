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
const var td = Engine.createAndRegisterTableData(0);

var lastChangedIndex = -99;

inline function onTableChanged(pointIndex)
{
    lastChangedIndex = pointIndex;
}

td.setContentCallback(onTableChanged);

// Modify a point -- fires callback with index
td.setTablePoint(0, 0.0, 0.5, 0.5);
// test
/compile

# Verify
/expect lastChangedIndex is 0
/exit
// end test
