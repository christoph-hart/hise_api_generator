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
// Title: Save and restore automation data
const var mah = Engine.createMidiAutomationHandler();

// Snapshot current state
var saved = mah.getAutomationDataObject();
Console.print("Saved " + saved.length + " entries");

// Restore the saved state (clears existing, then adds saved entries)
mah.setAutomationDataFromObject(saved);
// test
/compile

# Verify
/expect-logs ["Saved 0 entries"]
/expect mah.getAutomationDataObject().length is 0
/exit
// end test
