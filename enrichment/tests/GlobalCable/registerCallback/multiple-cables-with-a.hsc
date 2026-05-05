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
// Context: An envelope editor uses one cable per parameter stage.
// A shared control callback forwards each slider's value through
// its corresponding cable into the DSP network.

const var rm = Engine.getGlobalRoutingManager();

const var attackCable = rm.getCable("EnvAttack");
const var decayCable = rm.getCable("EnvDecay");
const var sustainCable = rm.getCable("EnvSustain");

const var allCables = [attackCable, decayCable, sustainCable];

const var attackKnob = Content.addKnob("Attack", 0, 0);
const var decayKnob = Content.addKnob("Decay", 150, 0);
const var sustainKnob = Content.addKnob("Sustain", 300, 0);

const var allKnobs = [attackKnob, decayKnob, sustainKnob];

// One callback handles all knobs by index lookup
inline function onEnvKnobChanged(component, value)
{
    local idx = allKnobs.indexOf(component);
    allCables[idx].setValueNormalised(value);
};

attackKnob.setControlCallback(onEnvKnobChanged);
decayKnob.setControlCallback(onEnvKnobChanged);
sustainKnob.setControlCallback(onEnvKnobChanged);
// test
attackKnob.set("saveInPreset", false);
decayKnob.set("saveInPreset", false);
sustainKnob.set("saveInPreset", false);
/compile

# Trigger
/ui set Attack.value 0.5
/ui set Sustain.value 0.8

# Verify
/expect attackCable.getValueNormalised() is 0.5
/expect sustainCable.getValueNormalised() is 0.8
/exit
// end test
