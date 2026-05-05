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

var lastPosition = -1.0;

inline function onDisplayChanged(position)
{
    lastPosition = position;
}

td.setDisplayCallback(onDisplayChanged);

// Query a value -- fires the display callback as a side effect
td.getTableValueNormalised(0.75);
// test
/compile

# Verify
/expect Math.abs(lastPosition - 0.75) < 0.01 is true
/exit
// end test
