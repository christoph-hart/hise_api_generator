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
list.setValue(60, 127);
Console.print(list.getValue(60));  // 127
// test
/compile

# Verify
/expect-logs ["127"]
/exit
// end test
