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
var a = [1, 2, 3];

var ref = a;
ref[0] = 99;
Console.print(a[0]); // 99 -- ref and a share the same array

var copy = a.clone();
copy[0] = 0;
Console.print(a[0]); // 99 -- copy is independent
// test
/compile

# Verify
/expect-logs ["99", "99"]
/exit
// end test
