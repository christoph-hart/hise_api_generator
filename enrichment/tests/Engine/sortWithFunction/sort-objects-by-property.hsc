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
// Title: Sort an array of objects by a numeric property
var items = [
    {"name": "C", "value": 3},
    {"name": "A", "value": 1},
    {"name": "B", "value": 2}
];

inline function compareByValue(a, b)
{
    return a.value - b.value;
}

Engine.sortWithFunction(items, compareByValue);
Console.print(items[0].name); // "A"
Console.print(items[1].name); // "B"
Console.print(items[2].name); // "C"
// test
/compile

# Verify
/expect items[0].name is "A"
/expect items[1].name is "B"
/expect items[2].name is "C"
/exit
// end test
