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
// Title: Reading playback speed via MidiProcessor attributes
// Context: Access the MidiPlayer's module attributes (like PlaybackSpeed)
// through the MidiProcessor interface for controlling loop speed

const var mp = Synth.getMidiPlayer("MidiPlayer1");
const var proc = mp.asMidiProcessor();

// MidiPlayer attribute indices:
// 0 = CurrentPosition, 1 = CurrentSequence, 2 = CurrentTrack,
// 3 = LoopEnabled, 4 = LoopStart, 5 = LoopEnd, 6 = PlaybackSpeed

var speed = proc.getAttribute(6);
Console.print("Playback speed: " + speed); // e.g. 1.0 = normal

// Use speed to calculate effective loop duration
var effectiveSpeed = speed * 8; // Convert to step grid units
// test
/compile

# Verify
/expect proc.getAttribute(6) is 1.0
/exit
// end test
