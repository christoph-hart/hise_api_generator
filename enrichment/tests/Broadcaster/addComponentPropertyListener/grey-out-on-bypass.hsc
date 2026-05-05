// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SimpleGain as "PropGain"
/exit

/script
/callback onInit
// end setup
// Title: Greying out controls when a module is bypassed via property binding
const var PropKnob1 = Content.addKnob("PropKnob1", 0, 0);
PropKnob1.set("saveInPreset", false);
const var PropKnob2 = Content.addKnob("PropKnob2", 150, 0);
PropKnob2.set("saveInPreset", false);
const var PropKnob3 = Content.addKnob("PropKnob3", 300, 0);
PropKnob3.set("saveInPreset", false);

// Context: A common pattern where a module's bypass state drives the visual
// appearance of its associated controls. The transform callback converts the
// bypass state (0/1) into a colour value for the itemColour property.

const var bc = Engine.createBroadcaster({
    "id": "BypassDisabler",
    "args": ["processorId", "parameterId", "value"]
});

bc.attachToModuleParameter("PropGain", "Bypassed", "bypassSource");

const var WHITE_ACTIVE = 0x88FFFFFF;
const var WHITE_DIMMED = 0x15FFFFFF;

const var controlKnobs = [Content.getComponent("PropKnob1"),
                          Content.getComponent("PropKnob2"),
                          Content.getComponent("PropKnob3")];

// The transform callback receives (targetIndex, processorId, parameterId, value)
// and must return the property value to set
bc.addComponentPropertyListener(controlKnobs, "itemColour",
    "dimOnBypass",
    function(targetIndex, processorId, parameterId, isBypassed)
{
    return isBypassed ? WHITE_DIMMED : WHITE_ACTIVE;
});
// test
/compile

# Verify
/wait 300ms
/expect Content.getComponent("PropKnob1").get("itemColour") == WHITE_ACTIVE is true
/expect Content.getComponent("PropKnob3").get("itemColour") == WHITE_ACTIVE is true
/exit
// end test
