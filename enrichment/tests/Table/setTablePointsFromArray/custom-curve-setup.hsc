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

td.setTablePointsFromArray([
    [0.0, 0.0, 0.3],
    [0.25, 0.1, 0.5],
    [0.5, 0.5, 0.5],
    [0.75, 0.9, 0.5],
    [1.0, 1.0, 0.7]
]);

var numPoints = td.getTablePointsAsArray().length;
var midVal = td.getTableValueNormalised(0.5);
// test
/compile

# Verify
/expect numPoints is 5
/expect Math.abs(midVal - 0.5) < 0.15 is true
/exit
// end test
