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
// Title: Catching accidental string values in data arrays
// Example: Validating data structure fields aren't corrupted to strings
// Context: When deserializing data, fields that should be objects or numbers
// can be corrupted to strings. assertNoString catches this data corruption.

var mixerData = [
    {Name: {path: "icon1.svg"}, Channel: 1},
    {Name: "corrupted_string", Channel: 2}  // Should be object, not string
];

// Check second entry - Name field is corrupted to string
Console.assertNoString(mixerData[1].Name); // Assertion fires
// test
/expect-compile throws "Assertion failure"
/exit
// end test
