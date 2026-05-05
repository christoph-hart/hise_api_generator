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
list.setValue(72, 100);
Console.print(list.getIndex(100));  // 60 (first match)
Console.print(list.getIndex(99));   // -1 (not found)
// test
/compile

# Verify
/expect-logs ["60", "-1"]
/exit
// end test
