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
// Title: Sequence change callback for UI refresh
// Context: Register a callback that fires when the MIDI data changes
// (load, edit, clear). Use this to rebuild UI elements like step
// sequencer displays. The callback fires once immediately on registration.

const var mp = Synth.getMidiPlayer("MidiPlayer1");

reg callbackCount = 0;

inline function onSequenceChange(player)
{
    callbackCount++;

    // Rebuild the step sequencer UI from the new MIDI data
    if (!player.isEmpty())
    {
        var ts = player.getTimeSignature();
        Console.print("Sequence changed: " + ts.NumBars + " bars, " +
                       ts.Nominator + "/" + ts.Denominator);
    }
}

mp.setSequenceCallback(onSequenceChange);
// The callback fires immediately, initializing the UI state
// test
/compile

# Verify
/wait 300ms
/expect callbackCount >= 1 is true
/exit
// end test
