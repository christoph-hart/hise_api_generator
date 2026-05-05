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
// Title: Inspect automation entries and find assignments for a specific parameter
// Context: A custom automation UI needs to check whether a particular parameter
// is already assigned to a CC and which CC number controls it.

const var mah = Engine.createMidiAutomationHandler();

// Read the full automation state as an array of JSON objects
var data = mah.getAutomationDataObject();

// Each entry has Controller, Channel, Processor, Attribute, Start, End, etc.
for (entry in data)
{
    Console.print("CC" + entry.Controller + " ch:" + entry.Channel
                  + " -> " + entry.Processor + "." + entry.Attribute
                  + " [" + entry.Start + " .. " + entry.End + "]");
}
// test
/compile

# Verify
/expect Array.isArray(data) is true
/expect data.length is 0
/exit
// end test
