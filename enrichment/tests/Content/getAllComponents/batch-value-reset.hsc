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
// Title: Batch value retrieval for send level controls
// Context: Retrieve groups of related controls by pattern to read or
// write their values collectively.

Content.makeFrontInterface(900, 600);

// Create mixer channel sliders
for (i = 0; i < 3; i++)
{
    var dSlider = Content.addKnob("MixerCh" + (i+1) + "DelaySlider", 10, i * 50);
    dSlider.set("saveInPreset", false);
    dSlider.setValue(0.5);
    var rSlider = Content.addKnob("MixerCh" + (i+1) + "RevSlider", 150, i * 50);
    rSlider.set("saveInPreset", false);
    rSlider.setValue(0.7);
}

const var delaySends = Content.getAllComponents("Mixer.*DelaySlider");
const var reverbSends = Content.getAllComponents("Mixer.*RevSlider");

// Reset all send levels to zero
for (s in delaySends)
    s.setValue(0.0);

for (s in reverbSends)
    s.setValue(0.0);
// test
/compile

# Verify
/expect delaySends.length is 3
/expect delaySends[0].getValue() is 0.0
/expect reverbSends[1].getValue() is 0.0
/exit
// end test
