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
// Context: When assertTrue would be cryptic, assertWithMessage provides
// context-specific error messages that include runtime values.

const var index = -5;

Console.assertWithMessage(index >= 0, "Index must not be negative, got: " + index);
// test
/expect-compile throws "Index must not be negative, got: -5"
/exit
// end test
