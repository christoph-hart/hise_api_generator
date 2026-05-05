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
// Title: Test if any element matches a condition
var a = [1, 2, 3, 4, 5];
Console.print(a.some(function(x){ return x > 4; }));
Console.print(a.some(function(x){ return x > 10; }));
// test
/compile

# Verify
/expect-logs ["1", "0"]
/exit
// end test
