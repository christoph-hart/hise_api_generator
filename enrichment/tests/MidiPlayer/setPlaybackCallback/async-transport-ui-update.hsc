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
// Title: Async playback callback for UI state updates
// Context: Register an async (UI-thread) callback to update transport button
// state and handle recording transitions. Use the async mode (0) since
// the callback updates UI components.

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.create(4, 4, 1);

reg isRecording = false;
reg lastState = -1;

inline function onPlaybackChange(timestamp, playState)
{
    lastState = playState;

    // playState: 0 = stop, 1 = play, 2 = record
    if (playState == 2 && !isRecording)
    {
        // Just entered recording
        isRecording = true;
    }

    if (playState != 2 && isRecording)
    {
        // Recording just stopped - sequence data was flushed automatically
        isRecording = false;
    }
}

// Pass 0 for async (UI thread) - safe for component updates
mp.setPlaybackCallback(onPlaybackChange, 0);
// test
mp.play(0);
/compile

# Verify
/wait 300ms
/expect lastState is 1
/exit
// end test
