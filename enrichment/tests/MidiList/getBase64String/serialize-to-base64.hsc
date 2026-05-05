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
Console.print(typeof encoded);  // string
// test
/compile

# Verify
/expect-logs ["string"]
/exit
// end test
