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
const var mah = Engine.createMidiAutomationHandler();
var data = mah.getAutomationDataObject();

for (entry in data)
{
    Console.print("CC" + entry.Controller + " -> " + entry.Processor + "." + entry.Attribute);
}
// test
/compile

# Verify
/expect Array.isArray(data) is true
/expect data.length is 0
/exit
// end test
