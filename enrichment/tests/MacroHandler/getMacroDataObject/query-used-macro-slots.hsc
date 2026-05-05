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
// Title: Querying which macro slots are in use
// Context: Scan macro connections to determine which slots are occupied,
// e.g. to build a context menu with available/occupied indicators

const var mh = Engine.createMacroHandler();

var data = mh.getMacroDataObject();

// Build a set of occupied macro slot indices
const var usedSlots = [];

for (item in data)
{
    usedSlots.push(item.MacroIndex);
    Console.print("Macro " + item.MacroIndex + " -> "
                  + item.Attribute
                  + (item.CustomAutomation ? " (custom)" : ""));
}

Console.print("Used slots: " + usedSlots.length);
// test
/compile

# Verify
/expect Array.isArray(data) is true
/expect usedSlots.length is 0
/exit
// end test
