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
const var rm = Engine.getGlobalRoutingManager();

// Create a instance of a cable
const var c1 = rm.getCable("myDataCable");

// Create a duplicate instance
const var c2 = rm.getCable("myDataCable");

// Register two callbacks to both objects
c1.registerDataCallback(x => Console.print("C1 executed: " + trace(x)));
c2.registerDataCallback(x => Console.print("C2 executed: " + trace(x)));

Console.print("Send through cable 1");
c1.sendData("some data");

Console.print("Send through cable 2");
c2.sendData("some data");

// Output:
// Interface: Send through cable 1
// Interface: C2 executed: "some data"
// Interface: Send through cable 2
// Interface: C1 executed: "some data"
// test
/compile

# Verify
/expect-logs ["Send through cable 1", "C2 executed: \"some data\"", "Send through cable 2", "C1 executed: \"some data\""]
/exit
// end test
