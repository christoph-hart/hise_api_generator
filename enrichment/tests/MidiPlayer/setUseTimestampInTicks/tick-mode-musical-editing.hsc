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
// Title: Setting up tick mode for musical editing
// Context: Always enable tick mode early in initialization when building
// a step sequencer. Tick timestamps align to musical grid positions
// regardless of tempo changes.

const var mp = Synth.getMidiPlayer("MidiPlayer1");

// Enable tick mode before any getEventList/flushMessageList calls
mp.setUseTimestampInTicks(true);
mp.create(4, 4, 1);

// Now timestamps are in MIDI ticks (960 per quarter note)
var tpq = mp.getTicksPerQuarter(); // Always 960

// Common grid divisions in ticks:
// Whole note    = tpq * 4 = 3840
// Half note     = tpq * 2 = 1920
// Quarter note  = tpq     = 960
// 8th note      = tpq / 2 = 480
// 16th note     = tpq / 4 = 240
// 32nd note     = tpq / 8 = 120
// Triplet 8th   = tpq / 3 = 320

// Create a note at the second 16th note position
var noteList = [];
var on = Engine.createMessageHolder();
var off = Engine.createMessageHolder();
on.setType(on.NoteOn);
off.setType(on.NoteOff);
on.setNoteNumber(64);
off.setNoteNumber(64);
on.setVelocity(100);
on.setChannel(1);
off.setChannel(1);
on.setTimestamp(240); // second 16th note
off.setTimestamp(480);
noteList.push(on);
noteList.push(off);
mp.flushMessageList(noteList);

var events = mp.getEventList();

for (e in events)
{
    if (e.isNoteOn())
    {
        // Timestamp is now in ticks, e.g. 240 = second 16th note
        var stepIndex = parseInt(e.getTimestamp() / (tpq / 4));
        Console.print("Step " + stepIndex);
    }
}
// test
/compile

# Verify
/expect tpq is 960
/expect events[0].getTimestamp() is 240
/exit
// end test
