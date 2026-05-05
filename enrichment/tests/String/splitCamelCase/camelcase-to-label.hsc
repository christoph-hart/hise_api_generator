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
// Title: Convert internal camelCase IDs to human-readable labels
// Context: NKS integration and display labels need space-separated
// words from camelCase module attribute names.

var attributeName = "SendFilterReverbPreDelay";

// Strip the "Send" prefix (4 characters), then split and rejoin with spaces
var label = attributeName.substring(4, 10000).splitCamelCase().join(" ");
Console.print(label); // Filter Reverb Pre Delay
// test
/compile

# Verify
/expect-logs ["Filter Reverb Pre Delay"]
/exit
// end test
