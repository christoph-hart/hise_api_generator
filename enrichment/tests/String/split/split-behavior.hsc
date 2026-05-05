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
var csv = "one,two,three";
var parts = csv.split(",");
Console.print(parts[0]); // one
Console.print(parts[1]); // two
Console.print(parts[2]); // three

// Empty separator splits into individual characters
var chars = "abc".split("");
Console.print(chars.length); // 3
// test
/compile

# Verify
/expect-logs ["one", "two", "three", "3"]
/exit
// end test
