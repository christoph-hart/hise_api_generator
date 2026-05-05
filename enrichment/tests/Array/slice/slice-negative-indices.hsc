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
var a = [10, 20, 30, 40, 50];
var mid = a.slice(1, 3);
var last2 = a.slice(-2);
Console.print(mid.join(", "));
Console.print(last2.join(", "));
// test
/compile

# Verify
/expect-logs ["20, 30", "40, 50"]
/exit
// end test
