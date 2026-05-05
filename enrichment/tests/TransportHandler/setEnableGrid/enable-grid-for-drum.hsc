// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add MidiPlayer as "MIDIPlayer 1"
add MidiPlayer as "MIDIPlayer 2"
add MidiPlayer as "MIDIPlayer 3"
/exit

/script
/callback onInit
// end setup
const var th0 = Engine.createTransportHandler();
th0.setSyncMode(th0.InternalOnly);
th0.stopInternalClock(0);

// Context: A drum machine enables a 1/8 note grid (tempo factor 8) and syncs
// its MidiPlayers to the master clock. The grid provides the timing backbone --
// MidiPlayers follow it automatically via setSyncToMasterClock.
const var th = Engine.createTransportHandler();

var players = [
    Synth.getMidiPlayer("MIDIPlayer 1"),
    Synth.getMidiPlayer("MIDIPlayer 2"),
    Synth.getMidiPlayer("MIDIPlayer 3")
];

// Create empty sequences so sync has something to work with
for (mp in players)
    mp.create(4, 4, 1);

// Enable 1/8 note grid for the sequencer
th.setEnableGrid(true, 8);
// Use internal clock so the example runs without a DAW
th.setSyncMode(th.PreferInternal);
// Automatically stop the internal clock when the DAW transport stops
th.stopInternalClockOnExternalStop(true);

// Sync all MidiPlayers to the master clock grid
for (mp in players)
    mp.setSyncToMasterClock(true);
// test
th.startInternalClock(0);
/compile

# Verify
/expect th.isPlaying() is true
/wait 500ms
/expect Synth.getMidiPlayer('MIDIPlayer 1').getPlaybackPosition() > 0.0 is true
/exit
// end test
