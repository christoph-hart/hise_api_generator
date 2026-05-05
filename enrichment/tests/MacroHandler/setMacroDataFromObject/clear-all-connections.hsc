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
// Context: When using a custom preset model, clear macro state at
// startup so the preset loader starts from a known empty state

const var mh = Engine.createMacroHandler();
mh.setExclusiveMode(true);

// Clear all macro connections - the update callback fires once after this
mh.setMacroDataFromObject([]);

var data = mh.getMacroDataObject();
// test
/compile

# Verify
/expect data.length is 0
/exit
// end test
