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
// Context: When component IDs encode their type in the first few
// characters, substring provides a lightweight prefix check.

var id = "FilterCutoff1";

if (id.substring(0, 6) == "Filter")
    Console.print("Filter parameter");
else if (id.substring(0, 6) == "Player")
    Console.print("Player parameter");
// test
/compile

# Verify
/expect-logs ["Filter parameter"]
/exit
// end test
