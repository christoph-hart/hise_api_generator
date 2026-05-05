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
Console.print(list.isEmpty());  // 1 (true - newly created lists are empty)
list.setValue(0, 42);
Console.print(list.isEmpty());  // 0 (false)
// test
/compile

# Verify
/expect-logs ["1", "0"]
/exit
// end test
