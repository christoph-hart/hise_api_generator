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
// Title: Default numeric sort and custom descending sort
var a = [3, 1, 4, 1, 5];

a.sort();
Console.print(a.join(", "));

a.sort(function(x, y){ return y - x; });
Console.print(a.join(", "));
// test
/compile

# Verify
/expect-logs ["1, 1, 3, 4, 5", "5, 4, 3, 1, 1"]
/exit
// end test
