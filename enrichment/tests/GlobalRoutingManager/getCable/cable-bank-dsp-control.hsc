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
// Title: Creating a bank of cables for DSP network parameter control
// Context: A custom envelope editor sends attack/decay/sustain/retrigger
// values into a DSP network through GlobalCable nodes.

const var rm = Engine.getGlobalRoutingManager();

// Create cables that match the processorId of GlobalCable nodes
// in the DSP network
const var attackCable = rm.getCable("EnvelopeAttack");
const var decayCable = rm.getCable("EnvelopeDecay");
const var sustainCable = rm.getCable("EnvelopeSustain");
const var retriggerCable = rm.getCable("EnvelopeRetrigger");

// Store in an array for indexed access from UI callbacks
const var allCables = [attackCable, decayCable, sustainCable, retriggerCable];

const var attackKnob = Content.addKnob("Attack", 0, 0);
const var decayKnob = Content.addKnob("Decay", 150, 0);
const var sustainKnob = Content.addKnob("Sustain", 300, 0);
const var retriggerBtn = Content.addButton("Retrigger", 450, 0);

const var allControls = [attackKnob, decayKnob, sustainKnob, retriggerBtn];

// Single callback routes any control to its matching cable
inline function onParameterChange(component, value)
{
    local idx = allControls.indexOf(component);
    allCables[idx].setValueNormalised(value);
};

for (c in allControls)
{
    c.set("saveInPreset", false);
    c.setControlCallback(onParameterChange);
}
// test
/compile

# Trigger
/ui set Attack.value 0.7

# Verify
/expect attackCable.getValueNormalised() is 0.7
/exit
// end test
