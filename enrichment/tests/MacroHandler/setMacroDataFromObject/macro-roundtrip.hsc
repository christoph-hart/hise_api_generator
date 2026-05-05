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
// Title: Save and restore macro connections
const var mh = Engine.createMacroHandler();

// Snapshot current connections (returns a copy, not a live reference)
var savedData = mh.getMacroDataObject();

// Clear all connections
mh.setMacroDataFromObject([]);

// Restore from the saved snapshot
mh.setMacroDataFromObject(savedData);

var restored = mh.getMacroDataObject();
// test
/compile

# Verify
/expect Array.isArray(savedData) is true
/expect restored.length is 0
/exit
// end test
