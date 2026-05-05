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
Content.makeFrontInterface(600, 300);
const var knob = Content.addKnob("CExKnob1", 10, 10);
const var found = Content.componentExists("CExKnob1");
const var missing = Content.componentExists("NonExistent");
// test
/compile

# Verify
/expect found is true
/expect missing is false
/exit
// end test
