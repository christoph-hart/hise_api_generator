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
// Title: Link two table data objects to share the same curve
const var td1 = Engine.createAndRegisterTableData(0);
const var td2 = Engine.createAndRegisterTableData(1);

// Set a custom curve on td1
td1.setTablePointsFromArray([
    [0.0, 0.0, 0.5],
    [0.5, 1.0, 0.5],
    [1.0, 0.0, 0.5]
]);

// Link td2 to td1 -- they now share the same data
td2.linkTo(td1);

// Querying td2 returns td1's curve
var val = td2.getTableValueNormalised(0.5);
// test
/compile

# Verify
/expect Math.abs(val - 1.0) < 0.05 is true
/exit
// end test
