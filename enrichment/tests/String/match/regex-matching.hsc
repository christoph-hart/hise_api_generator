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
// Title: Extract numeric values with regex
var text = "Width: 100px, Height: 200px";
var numbers = text.match("[0-9]+");

Console.print(numbers.length); // 2
Console.print(numbers[0]);     // 100
Console.print(numbers[1]);     // 200
// test
/compile

# Verify
/expect-logs ["2", "100", "200"]
/exit
// end test
