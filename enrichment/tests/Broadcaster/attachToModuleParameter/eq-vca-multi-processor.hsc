// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add CurveEq as "MasterEQ"
add CurveEq as "MidEQ"
add CurveEq as "SideEQ"
/exit

/script
/callback onInit
// end setup
// Title: EQ Virtual Control Array - one set of knobs controls multiple EQ processors
const var EQFreqK = Content.addKnob("EQFreqK", 0, 0);
EQFreqK.set("saveInPreset", false);
const var EQGainK = Content.addKnob("EQGainK", 150, 0);
EQGainK.set("saveInPreset", false);
const var EQQK = Content.addKnob("EQQK", 300, 0);
EQQK.set("saveInPreset", false);

// Context: When a plugin has multiple EQ processors (e.g., master/mid/side in a
// stereo FX chain), a single broadcaster watching all processors keeps shared VCA
// knobs in sync with whichever processor is currently active.

const var EQs = [Synth.getEffect("MasterEQ"),
                 Synth.getEffect("MidEQ"),
                 Synth.getEffect("SideEQ")];

const var vcaKnobs = [Content.getComponent("EQGainK"),
                      Content.getComponent("EQFreqK"),
                      Content.getComponent("EQQK")];

// Build parameter index list: 4 bands x 5 params each = 20 parameters
const var EQ_PARAMS = [];
for (i = 0; i < 20; i++)
    EQ_PARAMS.push(i);

reg currentBand = 0;
reg currentEqIndex = 0;

const var paramWatcher = Engine.createBroadcaster({
    "id": "EQParamSync",
    "args": ["processorId", "parameterId", "value"]
});

// Watch all 20 parameters across all 3 EQ processors
paramWatcher.attachToModuleParameter(
    ["MasterEQ", "MidEQ", "SideEQ"],
    EQ_PARAMS,
    "syncVCA"
);

// Only update knobs for the active EQ and selected band
paramWatcher.addListener("", "updateVCA", function(eqId, paramIndex, value)
{
    if (EQs[currentEqIndex].getId() != eqId)
        return;

    // Check if this parameter belongs to the currently selected band
    local bandOffset = currentBand * 5;

    if (paramIndex >= bandOffset && paramIndex < bandOffset + 3)
        vcaKnobs[paramIndex - bandOffset].setValue(value);
});
// test
/compile

# Verify
/wait 300ms
/expect paramWatcher.processorId is "SideEQ"
/exit
// end test
