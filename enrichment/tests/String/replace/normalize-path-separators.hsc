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
// Context: File paths may use backslashes on Windows. Replace them
// with forward slashes for consistent display and parsing.

var fullPath = "Samples\\Drums\\Kick.wav";
var normalized = fullPath.replace("\\", "/");
var parts = normalized.split("/");
Console.print(parts[2]); // Kick.wav
// test
/compile

# Verify
/expect-logs ["Kick.wav"]
/exit
// end test
