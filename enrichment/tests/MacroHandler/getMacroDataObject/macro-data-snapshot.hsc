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
const var mh = Engine.createMacroHandler();
var data = mh.getMacroDataObject();

for (item in data)
{
    Console.print("Macro " + item.MacroIndex + ": " + item.Processor + "." + item.Attribute);
}
// test
/compile

# Verify
/expect Array.isArray(data) is true
/expect data.length is 0
/exit
// end test
