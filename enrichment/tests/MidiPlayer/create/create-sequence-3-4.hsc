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
mp.clearAllSequences();
mp.create(3, 4, 8);
// test
/compile

# Verify
/expect mp.getNumSequences() is 1
/expect mp.getTimeSignature().Nominator is 3
/expect mp.getTimeSignature().NumBars is 8
/exit
// end test
