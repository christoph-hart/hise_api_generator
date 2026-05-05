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
Content.makeFrontInterface(900, 600);

// Disable position updates -- layout is managed by script
Content.setUpdateExistingPosition(false);

const var btn = Content.addButton("DynBtn", 10, 10);
// On recompile, "DynBtn" will NOT be moved back to (10, 10)
// if it was repositioned at runtime
// test
/compile

# Verify
/expect isDefined(btn) is true
/exit
// end test
