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
// Title: Test if all elements satisfy a condition
var a = [2, 4, 6, 8];
Console.print(a.every(function(x){ return x % 2 == 0; }));
Console.print(a.every(function(x){ return x > 5; }));
// test
/compile

# Verify
/expect-logs ["1", "0"]
/exit
// end test
