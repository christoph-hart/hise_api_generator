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
// Context: When component IDs follow a strict naming format like
// "MixerStrip01", substring extracts a specific character range
// to parse as a number.

var componentId = "MixerStrip07";

// Extract characters 10-12 to get the two-digit index
var idx = parseInt(componentId.substring(10, 12));
Console.print(idx); // 7
// test
/compile

# Verify
/expect-logs ["7"]
/exit
// end test
