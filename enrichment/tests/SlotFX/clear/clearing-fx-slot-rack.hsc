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

/script
/callback onInit
// end setup
// Context: When the user selects "Off" or closes an effect panel,
// the slot needs to return to unity-gain passthrough.

const var NUM_SLOTS = 4;
const var slots = [];

for (i = 0; i < NUM_SLOTS; i++)
    slots[i] = Synth.getSlotFX("EffectSlot" + (i + 1));

// Clear a specific slot back to passthrough
inline function clearSlot(slotIndex)
{
    slots[slotIndex].clear();

    // Any Effect handle from a previous setEffect() call is now invalid
}

clearSlot(0);
// test
slots[0].setEffect("SimpleReverb");
reg preId = slots[0].getCurrentEffectId();
/compile

# Verify
/expect preId is "SimpleReverb"
/expect postId != preId is true
/exit
// end test
