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
// Register a data callback to receive JSON chunks
const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("DataCable");

inline function onDataReceived(data)
{
    Console.print("Received note: " + data.noteNumber);
};

cable.registerDataCallback(onDataReceived);
// test
// Use a second reference to bypass the recursion guard
const var triggerCable = rm.getCable("DataCable");
triggerCable.sendData({"noteNumber": 42});
/compile

# Verify
/expect-logs ["Received note: 42"]
/exit
// end test
