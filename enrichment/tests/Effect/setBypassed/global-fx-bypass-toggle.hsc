// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "ChannelEq 1"
add SimpleGain as "ChannelEq 2"
add SimpleGain as "MasterComp"
add SimpleGain as "MasterLimiter"
/exit

/script
/callback onInit
// end setup
// Title: Global FX bypass with state preservation
// Context: A "bypass all FX" toggle that saves each effect's current
// bypass state before engaging, and restores it when disengaging.
const var NUM_CHANNELS = 2;
const var fxModules = [];

for (i = 0; i < NUM_CHANNELS; i++)
    fxModules.push(Synth.getEffect("ChannelEq " + (i + 1)));

fxModules.push(Synth.getEffect("MasterComp"));
fxModules.push(Synth.getEffect("MasterLimiter"));

// Store the per-effect bypass state before the global bypass
const var savedBypassStates = {};
reg globalBypassActive = false;

inline function toggleGlobalBypass()
{
    globalBypassActive = !globalBypassActive;

    if (globalBypassActive)
    {
        // Save each effect's current state, then bypass all
        for (fx in fxModules)
        {
            savedBypassStates[fx.getId()] = fx.isBypassed();
            fx.setBypassed(true);
        }
    }
    else
    {
        // Restore each effect's individual bypass state
        for (fx in fxModules)
            fx.setBypassed(savedBypassStates[fx.getId()]);
    }
}
// test
toggleGlobalBypass();
/compile

# Verify
/expect globalBypassActive is 1
/expect fxModules[0].isBypassed() is 1
/expect fxModules[3].isBypassed() is 1
/exit
// end test
