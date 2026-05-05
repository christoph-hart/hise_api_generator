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
list.setValue(60, 100);
Console.print(list.getValue(60));   // 100
Console.print(list.getValue(200));  // -1 (out of range)
// test
/compile

# Verify
/expect-logs ["100", "-1"]
/exit
// end test
