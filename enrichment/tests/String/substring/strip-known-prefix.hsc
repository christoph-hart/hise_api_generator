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
// Title: Strip a known prefix from a module attribute name
// Context: Module attributes often have a common prefix (e.g., "Master"
// or "SendFx"). Use substring to remove the prefix before further
// processing like splitCamelCase.

var attribute = "MasterCompThreshold";

// Skip the "Master" prefix (6 characters)
var paramName = attribute.substring(6, 10000).splitCamelCase().join(" ");
Console.print(paramName); // Comp Threshold
// test
/compile

# Verify
/expect-logs ["Comp Threshold"]
/exit
// end test
