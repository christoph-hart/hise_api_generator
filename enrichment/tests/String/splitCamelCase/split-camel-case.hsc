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
// Title: Split camelCase identifiers into word tokens
var name = "myValueTest";
var parts = name.splitCamelCase();

Console.print(parts[0]); // my
Console.print(parts[1]); // Value
Console.print(parts[2]); // Test
// test
/compile

# Verify
/expect-logs ["my", "Value", "Test"]
/exit
// end test
