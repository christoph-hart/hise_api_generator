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
// Context: Raw file names use underscores and hyphens as separators.
// A replace chain normalizes them into user-friendly display text.

var fileName = "bright_warm-pad";
var label = fileName.replace("_", " ").replace("-", " ").toUpperCase();
Console.print(label); // BRIGHT WARM PAD
// test
/compile

# Verify
/expect-logs ["BRIGHT WARM PAD"]
/exit
// end test
