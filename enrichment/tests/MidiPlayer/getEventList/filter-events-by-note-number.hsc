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
var onA = Engine.createMessageHolder();
var offA = Engine.createMessageHolder();
onA.setType(onA.NoteOn);
offA.setType(onA.NoteOff);
onA.setNoteNumber(64);
offA.setNoteNumber(64);
onA.setVelocity(100);
onA.setChannel(1);
offA.setChannel(1);
onA.setTimestamp(0);
offA.setTimestamp(240);
setupNotes.push(onA);
setupNotes.push(offA);
__mp.flushMessageList(setupNotes);

// Context: Extract events, filter by type and note number, and compute
// step positions from tick timestamps for a step sequencer UI

const var mp = Synth.getMidiPlayer("MidiPlayer1");
var events = mp.getEventList();
var tpq = mp.getTicksPerQuarter(); // 960

// Filter to only note-on events for a specific note
var noteOns = events.filter(function(e)
{
    return e.isNoteOn() && e.getNoteNumber() == 64;
});

// Convert tick timestamps to step positions (16th note grid)
var stepSize = tpq / 4; // 240 ticks per 16th note

for (e in noteOns)
{
    var stepIndex = parseInt(e.getTimestamp() / stepSize);
    var velocity = e.getVelocity() / 127.0;
    Console.print("Step " + stepIndex + ": velocity " + velocity);
}
// test
/compile

# Verify
/expect noteOns.length is 1
/expect noteOns[0].getNoteNumber() is 64
/exit
// end test
