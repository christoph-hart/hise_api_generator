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

// Store values in two different data slots for event ID 1
rm.setEventData(1, 0, 0.75);
rm.setEventData(1, 1, 440.0);

// Read back stored values
var slot0 = rm.getEventData(1, 0);
var slot1 = rm.getEventData(1, 1);
var empty = rm.getEventData(1, 2);

Console.print("Slot 0: " + slot0); // Slot 0: 0.75
Console.print("Slot 1: " + slot1); // Slot 1: 440
Console.print("Slot 2: " + empty); // Slot 2: undefined
// test
/compile

# Verify
/expect rm.getEventData(1, 0) is 0.75
/expect rm.getEventData(1, 1) is 440.0
/expect rm.getEventData(1, 2) is undefined
/exit
// end test
