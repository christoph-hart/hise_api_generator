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
// Context: Sample map IDs use "/" as a path separator. Splitting
// extracts the category and the individual sample name.

var sampleMapId = "Drums/Kicks/HardKick";
var parts = sampleMapId.split("/");

var category = parts[0];  // "Drums"
var subFolder = parts[1]; // "Kicks"
var name = parts[2];      // "HardKick"
Console.print(category + " > " + name); // Drums > HardKick
// test
/compile

# Verify
/expect-logs ["Drums > HardKick"]
/exit
// end test
