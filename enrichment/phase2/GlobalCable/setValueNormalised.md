## setValueNormalised

**Examples:**

```javascript
// Title: Forwarding slider values to DSP network via cable
// Context: Hidden sliders drive envelope parameters in a DSP network.
// The user interacts with a custom ScriptPanel editor; when the panel
// updates a slider, its control callback pushes the normalised value
// through the corresponding cable into a routing.global_cable node.

const var rm = Engine.getGlobalRoutingManager();

const var attackCable = rm.getCable("EnvAttack");
const var decayCable = rm.getCable("EnvDecay");
const var sustainCable = rm.getCable("EnvSustain");
const var retriggerCable = rm.getCable("EnvRetrigger");

const var allCables = [attackCable, decayCable, sustainCable, retriggerCable];

const var attack = Content.addKnob("Attack", 0, 0);
const var decay = Content.addKnob("Decay", 150, 0);
const var sustain = Content.addKnob("Sustain", 300, 0);
const var retrigger = Content.addButton("Retrigger", 450, 0);

const var allControls = [attack, decay, sustain, retrigger];

inline function onControlChanged(component, value)
{
    local idx = allControls.indexOf(component);
    allCables[idx].setValueNormalised(value);
};

attack.setControlCallback(onControlChanged);
decay.setControlCallback(onControlChanged);
sustain.setControlCallback(onControlChanged);
retrigger.setControlCallback(onControlChanged);

// Hide the sliders -- the ScriptPanel provides the visual interface
for (c in allControls)
    c.set("visible", false);
```
