// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "BypassTarget"
/exit

/script
/callback onInit
// end setup
const var CompThreshold = Content.addKnob("CompThreshold", 0, 0);
CompThreshold.set("saveInPreset", false);
const var CompRatio = Content.addKnob("CompRatio", 150, 0);
CompRatio.set("saveInPreset", false);
const var CompAttack = Content.addKnob("CompAttack", 300, 0);
CompAttack.set("saveInPreset", false);

// Context: Use the special "Bypassed" parameter ID to react to a module's
// bypass state and update the UI accordingly.

const var disabler = Engine.createBroadcaster({
    "id": "BypassWatcher2",
    "args": ["processorId", "parameterId", "value"]
});

disabler.attachToModuleParameter("BypassTarget", "Bypassed", "bypassState");

const var compKnobs = [Content.getComponent("CompThreshold"),
                       Content.getComponent("CompRatio"),
                       Content.getComponent("CompAttack")];

// Grey out knobs when the compressor is bypassed
disabler.addComponentPropertyListener(compKnobs, "enabled",
    "disableOnBypass",
    function(targetIndex, processorId, parameterId, isBypassed)
{
    return !isBypassed;
});
// test
/compile

# Verify
/expect Content.getComponent("CompThreshold").get("enabled") is true
/expect Content.getComponent("CompRatio").get("enabled") is true
/exit
// end test
