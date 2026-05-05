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
var a = [1, 12, 3, 14, 5];
var idx = a.findIndex(function(x){ return x > 10; });
Console.print(idx);
// test
/compile

# Verify
/expect-logs ["1"]
/exit
// end test
