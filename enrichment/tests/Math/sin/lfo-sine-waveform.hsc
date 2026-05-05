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
// Context: Visualising a sine LFO shape in a ScriptPanel paint
// routine by sampling Math.sin across the panel width.

const var WAVEFORM_WIDTH = 128;
const var p = Content.createPath();

for (i = 0; i < WAVEFORM_WIDTH; i += 2)
{
    local x = i / WAVEFORM_WIDTH;

    // Normalise sine output from [-1,1] to [0,1] for drawing
    local y = 0.5 * Math.sin(x * Math.PI * 2.0) + 0.5;

    if (i == 0)
        p.startNewSubPath(x, y);
    else
        p.lineTo(x, y);
}
// test
/compile

# Verify
/expect 0.5 * Math.sin(0.25 * Math.PI * 2.0) + 0.5 is 1.0
/expect Math.abs(0.5 * Math.sin(0.5 * Math.PI * 2.0) + 0.5 - 0.5) < 0.0001 is true
/exit
// end test
