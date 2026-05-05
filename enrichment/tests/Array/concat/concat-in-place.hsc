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
// Title: In-place concatenation (differs from JavaScript)
var a = [1, 2, 3];
a.concat([4, 5], [6, 7]);
Console.print(a.length);
Console.print(a.join(", "));
// test
/compile

# Verify
/expect-logs ["7", "1, 2, 3, 4, 5, 6, 7"]
/exit
// end test
