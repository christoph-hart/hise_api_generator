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
var a = [1, 2.0, "3"];
Console.print(a.indexOf(2));       // 1 (loose: int 2 matches double 2.0)
Console.print(a.indexOf(2, 0, 1)); // -1 (strict: int 2 != double 2.0)
// test
/compile

# Verify
/expect-logs ["1", "-1"]
/exit
// end test
