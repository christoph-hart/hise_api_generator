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
// Title: Setting component values with a transform callback
const var Knob1 = Content.addKnob("Knob1v", 0, 0);
const var Knob2 = Content.addKnob("Knob2v", 150, 0);
Knob1.set("saveInPreset", false);
Knob2.set("saveInPreset", false);

const var bc = Engine.createBroadcaster({
    "id": "ValueSync",
    "args": ["component", "value"]
});

inline function onValueTarget(targetIndex, component, value)
{
    if (targetIndex == 0)
        return value;

    return 1.0 - value;
}

bc.addComponentValueListener(["Knob1v", "Knob2v"], "invertSecond", onValueTarget);
// test
/compile

# Verify
/expect bc.sendSyncMessage(["Knob1v", 0.75]) || true is true
/expect Content.getComponent("Knob1v").getValue() is 0.75
/expect Content.getComponent("Knob2v").getValue() is 0.25
/exit
// end test
