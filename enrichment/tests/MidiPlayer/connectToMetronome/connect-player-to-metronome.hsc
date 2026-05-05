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
add MidiMetronome as "Metronome1"
/exit

/script
/callback onInit
// end setup
// Context: In a multi-channel sequencer, connect the metronome to whichever
// player best represents the current musical grid (e.g. the one with the
// most steps at the standard speed)

const var mp = Synth.getMidiPlayer("MidiPlayer1");

// Connect the player to a metronome module
mp.connectToMetronome("Metronome1");

// In a multi-player setup, reconnect when channel configuration changes
inline function updateMetronomeConnection()
{
    // Pick the player that best matches the main beat division
    mp.connectToMetronome("Metronome1");
}
// test
/compile

# Verify
/expect isDefined(mp) is true
/exit
// end test
