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
// Title: Find first element matching a condition
var a = [1, 12, 3, 14, 5];
var first = a.find(function(x){ return x > 10; });
Console.print(first);
// test
/compile

# Verify
/expect-logs ["12"]
/exit
// end test
