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
// Title: Constructing a CC event from scratch
const var mh = Engine.createMessageHolder();
mh.setType(mh.Controller);
mh.setChannel(1);
mh.setControllerNumber(1);
mh.setControllerValue(64);

Console.print(mh.dump());
Console.print(mh.isController());
// test
/compile

# Verify
/expect-logs ["Type: Controller, Channel: 1, Number: 1, Value: 64, EventId: 0, Timestamp: 0, ", "1"]
/exit
// end test
