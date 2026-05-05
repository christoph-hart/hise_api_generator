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
const var list = Engine.createMidiList();
list.setRange(0, 12, 100);  // Fill slots 0 through 11
Console.print(list.getValue(0));   // 100
Console.print(list.getValue(11));  // 100
Console.print(list.getValue(12));  // -1 (outside range)
// test
/compile

# Verify
/expect-logs ["100", "100", "-1"]
/exit
// end test
