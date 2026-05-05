// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "FxChain"
/exit

/script
/callback onInit
// end setup
// Context: Preset or state restore updates module internals first, then UI controls pull the new values.
const var connectedControls = [
    Content.addKnob("Drive", 0, 0),
    Content.addKnob("Tone", 80, 0),
    Content.addKnob("Mix", 160, 0)
];

for (c in connectedControls)
{
    c.set("processorId", "FxChain");
    c.set("parameterId", "Gain");
}

const var fx = Synth.getEffect("FxChain");

inline function syncControlsFromProcessor()
{
    for (c in connectedControls)
        c.updateValueFromProcessorConnection();
}

// Call this right after restoreState() or any non-UI parameter mutation path.
syncControlsFromProcessor();
// test
/compile

# Verify
/expect fx.setAttribute(fx.Gain, -9.0) || true is true
/expect syncControlsFromProcessor() || false is false
/expect fx.getAttribute(fx.Gain) is -9.0
/expect connectedControls[0].getValue() is -9.0
/exit
// end test
