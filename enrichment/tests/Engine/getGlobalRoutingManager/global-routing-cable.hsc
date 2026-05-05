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
const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("MyCable");
cable.setValue(0.75);
// test
/compile

# Verify
/expect cable.getValueNormalised() is 0.75
/exit
// end test
