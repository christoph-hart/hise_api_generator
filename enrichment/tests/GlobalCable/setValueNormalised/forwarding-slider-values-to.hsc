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
// Set normalized cable value and verify
const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("TestCable");

cable.setRange(0.0, 100.0);
cable.setValueNormalised(0.5);

Console.print("Normalised value: " + cable.getValueNormalised());
Console.print("Actual value: " + cable.getValue());
// test
/compile

# Verify
/expect-logs ["Normalised value: 0.5", "Actual value: 50.0"]
/exit
// end test
