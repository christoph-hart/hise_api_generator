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
// Title: Creating knobs and accessing the returned reference
Content.makeFrontInterface(600, 300);
const var vol = Content.addKnob("VolKn", 10, 10);
vol.setRange(0.0, 1.0, 0.01);
vol.set("defaultValue", 0.75);
// test
/compile

# Verify
/expect vol.get("max") is 1.0
/exit
// end test
