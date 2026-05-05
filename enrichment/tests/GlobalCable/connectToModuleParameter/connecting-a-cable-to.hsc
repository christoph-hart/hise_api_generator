// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "SimpleGain1"
/exit

/script
/callback onInit
// end setup
// Context: A cable drives a gain parameter directly, bypassing
// script callbacks entirely. The target range JSON maps the
// normalised 0..1 cable value to a dB range with smoothing
// to avoid zipper noise on rapid value changes.

const var rm = Engine.getGlobalRoutingManager();
const var gainCable = rm.getCable("MasterGain");

gainCable.connectToModuleParameter("SimpleGain1", "Gain", {
    "MinValue": -100.0,
    "MaxValue": 0.0,
    "SkewFactor": 5.0,
    "SmoothingTime": 50.0
});

// Now any setValue/setValueNormalised call on this cable
// automatically updates SimpleGain1's Gain parameter
gainCable.setValueNormalised(0.75);

// Get module reference for verification
const var gain = Synth.getEffect("SimpleGain1");
// test
/compile

# Verify cable side (audio-side smoother only ticks under live playback)
/expect gainCable.getValueNormalised() is 0.75
/exit
// end test
