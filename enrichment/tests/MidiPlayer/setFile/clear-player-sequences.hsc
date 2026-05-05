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
// Context: Pass an empty string to setFile() as a no-op, or clear with
// clearAllSequences() for a full reset

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.create(4, 4, 1);

// Clear all loaded MIDI data
mp.clearAllSequences();
// test
/compile

# Verify
/expect mp.getNumSequences() is 0
/exit
// end test
