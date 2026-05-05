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
// Context: After flushing new note data to a sequence, update the time
// signature to match the desired bar count. Read-modify-write pattern
// preserves existing time signature values.

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.create(4, 4, 4);

// Get the current time signature object
var ts = mp.getTimeSignature();

// Change only the bar count
ts.NumBars = 2;
mp.setTimeSignature(ts);
// test
/compile

# Verify
/expect mp.getTimeSignature().NumBars is 2
/expect mp.getTimeSignature().Nominator is 4
/exit
// end test
