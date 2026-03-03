## connectToGlobalModulator

**Examples:**

```javascript
// Title: Wiring global modulators to cables during module tree setup
// Context: After building a GlobalModulatorContainer with the Builder API,
// each modulator is connected to a named cable. This makes every
// modulation source (LFOs, envelopes, velocity, etc.) available as
// a cable value throughout the project.

const var rm = Engine.getGlobalRoutingManager();

// Modulator definitions: [type, name]
const var MODS = [
    ["FlexAHDSR", "AHDSR1"],
    ["FlexAHDSR", "AHDSR2"],
    ["LFO", "LFO1"],
    ["Velocity", "Velocity"],
    ["PitchWheel", "PitchWheel"]
];

// Connect each modulator to a cable with the same name.
// The modulator must be a child of a GlobalModulatorContainer.
for (m in MODS)
    rm.getCable(m[1]).connectToGlobalModulator(m[1], true);

// Now any script can read the modulator output:
// const var lfo = rm.getCable("LFO1");
// var currentValue = lfo.getValueNormalised();
```

**Cross References:**
- `Builder.create` -- used to construct the `GlobalModulatorContainer` and its child modulators before connecting them to cables.
