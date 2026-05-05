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
// Title: ignoreEvent flag does not corrupt event data or timestamp
const var mh = Engine.createMessageHolder();

mh.setType(mh.NoteOn);
mh.setNoteNumber(60);
mh.setVelocity(100);
mh.setChannel(1);
mh.setTimestamp(512);

// Setting and clearing the ignored flag must not alter the timestamp
// (the flag uses reserved bits in the timestamp field)
mh.ignoreEvent(true);
Console.print(mh.getTimestamp()); // 512 -- flag bits don't bleed through

mh.ignoreEvent(false);
Console.print(mh.getTimestamp()); // 512 -- still intact after clearing
// test
/compile

# Verify
/expect-logs ["512", "512"]
/exit
// end test
