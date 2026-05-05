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
var a = ["Alice", "Bob", "Charlie"];
a.forEach(function(name){ Console.print("Hello " + name); });
// test
/compile

# Verify
/expect-logs ["Hello Alice", "Hello Bob", "Hello Charlie"]
/exit
// end test
