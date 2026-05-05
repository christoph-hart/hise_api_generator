// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add SlotFX as "EffectSlot1"
add SlotFX as "EffectSlot2"
add SlotFX as "EffectSlot3"
add SlotFX as "EffectSlot4"
/exit

# Setup: UI scaffold
/ui
add ScriptSlider "FxKnob1" at 0 0 128 48
add ScriptSlider "FxKnob2" at 0 0 128 48
add ScriptSlider "FxKnob3" at 0 0 128 48
add ScriptSlider "FxKnob4" at 0 0 128 48
/exit

/script
/callback onInit
// end setup
// Context: An FX rack where users select effects from a popup menu.
// Each effect type is defined in a configuration object that maps
// the UI name to a module ID, parameter bindings, and a default state.

// Effect configuration: maps each effect to its module type and parameters
const var FX_CONFIG = {
    "chorus": {
        "moduleID": "Chorus",
        "parameterIds": ["Rate", "Width", "Feedback", "Delay"],
        "ranges": [[0, 1, 0.3], [0, 1, 0.43], [0, 1, 0.3], [0, 1, 1.0]]
    },
    "reverb": {
        "moduleID": "SimpleReverb",
        "parameterIds": ["WetLevel", "Damping", "Width", "RoomSize"],
        "ranges": [[0, 1, 0.2], [0, 1, 0.6], [0, 1, 0.8], [0, 1, 0.8]]
    },
    "delay": {
        "moduleID": "Delay",
        "parameterIds": ["DelayTimeLeft", "FeedbackLeft", "Mix"],
        "ranges": [[0, 1000, 200], [0, 1, 0.3], [0, 1, 0.5]]
    }
};

const var NUM_SLOTS = 4;
const var slots = [];
const var knobs = [];

// Get SlotFX references and knob arrays at init
for (i = 0; i < NUM_SLOTS; i++)
{
    slots[i] = Synth.getSlotFX("EffectSlot" + (i + 1));
    knobs[i] = Content.getComponent("FxKnob" + (i + 1));
}

// Load an effect into a slot by config key
inline function loadEffect(slotIndex, fxKey)
{
    if (fxKey == "empty")
    {
        slots[slotIndex].setEffect("EmptyFX");
        return;
    }

    local config = FX_CONFIG[fxKey];

    // setEffect returns the loaded Effect handle
    local fx = slots[slotIndex].setEffect(config.moduleID);

    // Bind UI knobs to the loaded effect's parameters
    local slotName = fx.getId();

    for (j = 0; j < config.parameterIds.length; j++)
    {
        knobs[slotIndex].set("processorId", slotName);
        knobs[slotIndex].set("parameterId", config.parameterIds[j]);
    }
}

loadEffect(0, "chorus");
loadEffect(1, "reverb");
// test
/compile

# Verify
/expect slots[0].getCurrentEffectId() is "Chorus"
/expect slots[1].getCurrentEffectId() is "SimpleReverb"
/exit
// end test
