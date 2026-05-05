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
mh.setType(mh.NoteOn);
mh.setNoteNumber(64);
mh.setVelocity(80);
mh.setChannel(1);

Console.print(mh.dump());
// test
/compile

# Verify
/expect-logs ["Type: NoteOn, Channel: 1, Number: 64, Value: 80, EventId: 0, Timestamp: 0, "]
/exit
// end test
