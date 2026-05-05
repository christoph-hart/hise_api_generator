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
// Context: When working with data that should be objects or arrays,
// assertIsObjectOrArray catches primitive values that would cause
// errors in subsequent property access or method calls.

const var moduleList = [
    {"id": "Osc1", "type": "Oscillator"},
    {"id": "Filter1", "type": "Filter"}
];

inline function processModule(module)
{
    Console.assertIsObjectOrArray(module);
    Console.print("Processing: " + module.id);
}

for (m in moduleList)
    processModule(m);

// Passing a string instead of an object triggers the assertion
processModule("not_an_object");
// test
/expect-compile throws "Assertion failure: value is not object or array"
/exit
// end test
