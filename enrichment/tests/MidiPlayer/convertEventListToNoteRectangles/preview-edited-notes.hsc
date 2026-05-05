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
// Context: Unlike getNoteRectangleList() which reads from the stored sequence,
// convertEventListToNoteRectangles() operates on an arbitrary event list.
// This is useful for visualizing a merged or modified set of events.

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.setUseTimestampInTicks(true);
mp.create(4, 4, 1);

// Create a simple event list with one note
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
on.setTimestamp(0);
off.setTimestamp(960);
noteList.push(on);
noteList.push(off);

// Convert the list to rectangles for visualization
var bounds = [0, 0, 500, 200];
var noteRects = mp.convertEventListToNoteRectangles(noteList, bounds);
Console.print("Rectangles: " + noteRects.length);
// test
/compile

# Verify
/expect noteRects.length is 1
/exit
// end test
