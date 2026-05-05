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
mp.create(4, 4, 1);

reg lastPlayState = -1;

// Async callback (safe for UI operations)
inline function onPlaybackChange(timestamp, playState)
{
    lastPlayState = playState;
}

mp.setPlaybackCallback(onPlaybackChange, 0);
// test
mp.play(0);
/compile

# Verify
/wait 300ms
/expect lastPlayState is 1
/exit
// end test
