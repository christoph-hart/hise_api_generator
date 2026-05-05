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
// Title: Enabling undo for a multi-channel sequencer
// Context: Enable the global undo manager during initialization so that
// all subsequent MIDI edits (flushMessageList, setTimeSignature) can be
// undone with Engine.undo()

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.setUseGlobalUndoManager(true);
mp.setUseTimestampInTicks(true);
mp.create(4, 4, 1);

// Create and flush some test data
var noteList = [];
var on = Engine.createMessageHolder();
var off = Engine.createMessageHolder();
on.setType(on.NoteOn);
off.setType(on.NoteOff);
on.setNoteNumber(60);
off.setNoteNumber(60);
on.setVelocity(100);
on.setChannel(1);
off.setChannel(1);
on.setTimestamp(0);
off.setTimestamp(960);
noteList.push(on);
noteList.push(off);
mp.flushMessageList(noteList);

// Undo reverts the edit
Engine.undo();
// test
/compile

# Verify
/expect mp.isSequenceEmpty(1) is 1
/exit
// end test
