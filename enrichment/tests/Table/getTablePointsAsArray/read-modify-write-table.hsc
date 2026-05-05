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
// Title: Read-modify-write pattern for table points
const var td = Engine.createAndRegisterTableData(0);

// Get current points
var points = td.getTablePointsAsArray();

// Modify the curve of the second-to-last point
points[points.length - 2][2] = 0.2;

// Write back the modified points
td.setTablePointsFromArray(points);
// test
/compile

# Verify
/expect td.getTablePointsAsArray()[0][2] is 0.2
/expect td.getTablePointsAsArray().length is 2
/exit
// end test
