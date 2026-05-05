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
// Context: After stripping a common prefix with substring, capitalize
// the remaining portion for use as a user-facing label.

var fullName = "factory-preset-warm-keys";
var shortName = fullName.substring(15, 10000);

// "warm-keys" -> "warm keys" -> "Warm Keys"
var label = shortName.replace("-", " ").capitalize();
Console.print(label); // Warm Keys
// test
/compile

# Verify
/expect-logs ["Warm Keys"]
/exit
// end test
