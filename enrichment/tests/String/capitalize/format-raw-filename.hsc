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
// Context: Audio file names often use underscores and lowercase.
// Replace separators with spaces, then capitalize for display.

var rawName = "bright_warm_pad";
var displayName = rawName.replace("_", " ").capitalize();
Console.print(displayName); // Bright Warm Pad
// test
/compile

# Verify
/expect-logs ["Bright Warm Pad"]
/exit
// end test
