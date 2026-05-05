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
list.fill(64);
Console.print(list.getValue(0));    // 64
Console.print(list.getValue(127));  // 64
// test
/compile

# Verify
/expect-logs ["64", "64"]
/exit
// end test
