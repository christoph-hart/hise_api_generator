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
// Send a frequency value through a cable with a custom range
const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("FreqCable");

cable.setRange(20.0, 20000.0);
cable.setValue(440.0);

Console.print("Value set: " + cable.getValue());
// test
/compile

# Verify
/expect-logs ["Value set: 440.0"]
/exit
// end test
