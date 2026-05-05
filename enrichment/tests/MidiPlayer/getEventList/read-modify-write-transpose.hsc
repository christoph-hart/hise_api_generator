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
const var __mp = Synth.getMidiPlayer("MidiPlayer1");
__mp.setUseTimestampInTicks(true);
__mp.create(4, 4, 1);
var setupNotes = [];
var onB = Engine.createMessageHolder();
var offB = Engine.createMessageHolder();
onB.setType(onB.NoteOn);
offB.setType(onB.NoteOff);
onB.setNoteNumber(60);
offB.setNoteNumber(60);
onB.setVelocity(100);
onB.setChannel(1);
offB.setChannel(1);
onB.setTimestamp(0);
offB.setTimestamp(960);
setupNotes.push(onB);
setupNotes.push(offB);
__mp.flushMessageList(setupNotes);

// Context: Get the event list, modify events in place, then flush back.
// This is the standard edit workflow for MIDI data.

const var mp = Synth.getMidiPlayer("MidiPlayer1");
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
