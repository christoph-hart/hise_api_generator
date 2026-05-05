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
list.fill(10);
list.setValue(0, 20);
list.setValue(1, 20);
Console.print(list.getValueAmount(10));  // 126
Console.print(list.getValueAmount(20));  // 2
// test
/compile

# Verify
/expect-logs ["126", "2"]
/exit
// end test
