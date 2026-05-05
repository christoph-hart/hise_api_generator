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
// Title: Setting up master-clock-synced MIDI playback
// Context: Configure the TransportHandler grid first, then sync all
// MidiPlayer instances. Transport is controlled via the clock, not play()/stop().

const var transportHandler = Engine.createTransportHandler();

// Enable the grid and set sync mode BEFORE syncing players
transportHandler.setEnableGrid(true, 8);
transportHandler.setSyncMode(transportHandler.PreferInternal);

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.create(4, 4, 1);
mp.setSyncToMasterClock(true);

// Transport is now driven by the clock, not play()/stop()
// Use transportHandler.startInternalClock(0) to begin playback
// Use transportHandler.stopInternalClock(0) to stop

// Verify play() is a no-op when synced
var playResult = mp.play(0);
// test
/compile

# Verify
/expect playResult is 0
/exit
// end test
