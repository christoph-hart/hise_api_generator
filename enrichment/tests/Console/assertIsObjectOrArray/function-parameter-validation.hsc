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
// Context: Utility functions that expect a module reference or
// structured data object use assertIsObjectOrArray as a type guard.

const var testModule = {"name": "TestModule", "level": 0.75};

inline function checkModuleType(module)
{
    Console.assertIsObjectOrArray(module);
    Console.print("Module validated: " + module.name);
}

checkModuleType(testModule);
// test
/compile

# Verify
/expect-logs ["Module validated: TestModule"]
/exit
// end test
