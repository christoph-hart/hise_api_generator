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
var a = [1, 2, 3, 4];
var doubled = a.map(function(x){ return x * 2; });
Console.print(doubled.join(", "));
// test
/compile

# Verify
/expect-logs ["2, 4, 6, 8"]
/exit
// end test
