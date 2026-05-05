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
var big = a.filter(function(x){ return x > 10; });
Console.print(big.join(", "));
// test
/compile

# Verify
/expect-logs ["12, 14"]
/exit
// end test
