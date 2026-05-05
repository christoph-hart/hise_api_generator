// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

/script
/callback onInit
// end setup
// Context: When a multi-channel instrument switches which processor
// the waveform displays, the playback cursor retains its old position.
// Reset it to the start after rebinding.

const var wf = Content.addAudioWaveform("Waveform1", 0, 0);

inline function onChannelSwitch(component, value)
{
    local playerIds = ["Player1", "Player2", "Player3", "Player4"];
    local idx = parseInt(value);

    // Rebind the waveform to the new channel's audio processor
    wf.set("processorId", playerIds[idx]);

    // Reset cursor -- without this, the ruler stays at the old position
    wf.setPlaybackPosition(0);

    wf.sendRepaintMessage();
}

// Demonstrate the reset call directly (no audio data needed for the API call)
wf.setPlaybackPosition(0.5);
wf.setPlaybackPosition(0);
// test
/compile

# Verify
/expect wf.getRangeEnd() is 0
/exit
// end test
