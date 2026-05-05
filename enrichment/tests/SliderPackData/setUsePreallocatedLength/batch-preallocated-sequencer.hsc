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
// Title: Batch-creating preallocated SliderPackData for a step sequencer
// Context: A step sequencer with multiple channels and parameter modes
// needs many SliderPackData objects that resize without reallocation.

const var NUM_CHANNELS = 4;
const var NUM_MODES = 3;  // e.g., velocity, pitch, probability
const var MAX_STEPS = 32;

const var packs = [];
reg packIndex = 0;

for (i = 0; i < NUM_CHANNELS * NUM_MODES; i++)
{
    packs.push(Engine.createAndRegisterSliderPackData(packIndex));
    packs[packIndex].setNumSliders(MAX_STEPS);
    packs[packIndex].setAllValues(0.0);
    packs[packIndex++].setUsePreallocatedLength(MAX_STEPS);
}

// Later: resize without allocation or value loss
packs[0].setValue(0, 0.8);
packs[0].setNumSliders(16);  // View narrows, value at index 0 preserved
packs[0].setNumSliders(32);  // View widens, all original values still intact

Console.print(packs[0].getValue(0)); // 0.8
// test
/compile

# Verify
/expect packs[0].getValue(0) is 0.8
/expect packs[0].getNumSliders() is 32
/exit
// end test
