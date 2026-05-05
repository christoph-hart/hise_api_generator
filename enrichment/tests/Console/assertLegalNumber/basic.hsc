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
// Example: Validating gain calculations before applying
// Context: Division operations can produce illegal numbers (infinity/NaN)
// that corrupt audio processing. assertLegalNumber catches these.

var inputLevel = 0.0;
var gain1 = 1.0 / inputLevel; // Division by zero creates infinity

Console.assertLegalNumber(gain1); // Assertion fires - infinity is illegal
// test
/expect-compile throws "value is not a legal number"
/exit
// end test
