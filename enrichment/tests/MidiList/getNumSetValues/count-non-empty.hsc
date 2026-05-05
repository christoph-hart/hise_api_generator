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
list.setValue(61, 80);
Console.print(list.getNumSetValues());  // 2
// test
/compile

# Verify
/expect-logs ["2"]
/exit
// end test
