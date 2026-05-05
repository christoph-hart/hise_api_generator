// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add MidiPlayer as "MidiPlayer1"
/exit

/script
/callback onInit
// end setup
const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.setUseTimestampInTicks(true);
mp.create(4, 4, 1);

// Populate with a test note
var noteList = [];
var on = Engine.createMessageHolder();
var off = Engine.createMessageHolder();
on.setType(on.NoteOn);
off.setType(on.NoteOff);
on.setNoteNumber(60);
off.setNoteNumber(60);
on.setVelocity(100);
on.setTimestamp(0);
off.setTimestamp(960);
on.setChannel(1);
off.setChannel(1);
noteList.push(on);
noteList.push(off);
mp.flushMessageList(noteList);

// Now transpose
var events = mp.getEventList();

for (e in events)
{
    if (e.isNoteOn() || e.isNoteOff())
        e.setNoteNumber(e.getNoteNumber() + 12);
}

mp.flushMessageList(events);
// test
/compile

# Verify
/expect mp.getEventList()[0].getNoteNumber() is 72
/exit
// end test
