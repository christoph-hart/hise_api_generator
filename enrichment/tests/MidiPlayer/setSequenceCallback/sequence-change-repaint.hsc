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
// Title: Sequence change callback triggering panel repaint
const var mp = Synth.getMidiPlayer("MidiPlayer1");
const var Panel1 = Content.addPanel("Panel1", 0, 0);

reg callbackFired = false;

inline function onSequenceChange(player)
{
    callbackFired = true;
    Panel1.repaint();
}

mp.setSequenceCallback(onSequenceChange);
// The callback fires immediately on registration
// test
/compile

# Verify
/wait 300ms
/expect callbackFired is true
/exit
// end test
