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
// Context: For arrays and objects, Console.print shows a memory address
// unless you wrap the value in trace() to get readable JSON output.

const var filter = { "name": "Bass", "active": true };

Console.print(trace(filter));
// test
/compile

# Verify
/expect-logs ["{\"name\": \"Bass\", \"active\": 1}"]
/exit
// end test
