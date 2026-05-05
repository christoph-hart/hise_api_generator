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
// Title: Constructing a timed note sequence with explicit timestamps
const var mh1 = Engine.createMessageHolder();
mh1.setType(mh1.NoteOn);
mh1.setNoteNumber(60);
mh1.setVelocity(100);
mh1.setChannel(1);
mh1.setTimestamp(0);

const var mh2 = Engine.createMessageHolder();
mh2.setType(mh2.NoteOn);
mh2.setNoteNumber(64);
mh2.setVelocity(80);
mh2.setChannel(1);
mh2.setTimestamp(44100);

Console.print(mh1.getTimestamp());
Console.print(mh2.getTimestamp());
// test
/compile

# Verify
/expect-logs ["0", "44100"]
/exit
// end test
