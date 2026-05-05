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
list.fill(42);
list.clear();
Console.print(list.isEmpty());  // 1
// test
/compile

# Verify
/expect-logs ["1"]
/exit
// end test
