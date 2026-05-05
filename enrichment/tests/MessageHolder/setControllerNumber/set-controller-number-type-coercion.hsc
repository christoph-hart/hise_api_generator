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
const var mh = Engine.createMessageHolder();
mh.setType(mh.Controller);
mh.setChannel(1);

// Setting CC number 128 converts the event type to PitchBend
mh.setControllerNumber(128);
mh.setControllerValue(8192);

Console.print(mh.dump());
// test
/compile

# Verify
/expect-logs ["Type: PitchBend, Channel: 1, Value: 8192, Timestamp: 0, "]
/exit
// end test
