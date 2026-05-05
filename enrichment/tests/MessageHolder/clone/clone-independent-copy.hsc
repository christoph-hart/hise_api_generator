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
// Title: Cloning a MessageHolder for independent modification
const var mh = Engine.createMessageHolder();
mh.setType(mh.NoteOn);
mh.setNoteNumber(60);
mh.setVelocity(100);
mh.setChannel(1);

var copy = mh.clone();
copy.setNoteNumber(72);

Console.print(mh.getNoteNumber());
Console.print(copy.getNoteNumber());
// test
/compile

# Verify
/expect-logs ["60", "72"]
/exit
// end test
