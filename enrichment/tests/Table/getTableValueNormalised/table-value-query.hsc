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
// Title: Query table values at multiple positions
const var td = Engine.createAndRegisterTableData(0);

// Default table is a linear ramp 0->1
var atStart = td.getTableValueNormalised(0.0);
var atMid = td.getTableValueNormalised(0.5);
var atEnd = td.getTableValueNormalised(1.0);

Console.print("Start: " + atStart);
Console.print("Mid: " + atMid);
Console.print("End: " + atEnd);
// test
/compile

# Verify
/expect Math.abs(atStart) < 0.01 is true
/expect Math.abs(atMid - 0.5) < 0.05 is true
/expect Math.abs(atEnd - 1.0) < 0.01 is true
/exit
// end test
