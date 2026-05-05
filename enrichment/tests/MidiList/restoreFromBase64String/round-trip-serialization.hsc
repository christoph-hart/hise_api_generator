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
const var encoded = list.getBase64String();

const var list2 = Engine.createMidiList();
list2.restoreFromBase64String(encoded);
Console.print(list2.getValue(0));  // 42
// test
/compile

# Verify
/expect-logs ["42"]
/exit
// end test
