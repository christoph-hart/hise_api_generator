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
// Title: Creating multiple pattern bank sequences
// Context: Initialize a player with multiple empty sequences (pattern banks)
// for a step sequencer. Each sequence is a separate pattern slot.

const var mp = Synth.getMidiPlayer("MidiPlayer1");
const var NUM_PATTERNS = 4;

mp.setUseTimestampInTicks(true);

// Clear any existing data
mp.clearAllSequences();

// Create 4 pattern banks, each 2 bars of 4/4
for (i = 0; i < NUM_PATTERNS; i++)
    mp.create(4, 4, 2);

// Select the first pattern (one-based indexing)
mp.setSequence(1);
// test
/compile

# Verify
/expect mp.getNumSequences() is 4
/expect mp.getTimeSignature().NumBars is 2
/exit
// end test
