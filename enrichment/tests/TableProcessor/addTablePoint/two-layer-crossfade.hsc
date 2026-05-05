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
// Title: Building a 2-layer equal-power crossfade
const var builder = Synth.createBuilder();
builder.clear();
var ss = builder.create(builder.SoundGenerators.SineSynth, "TestSynth", 0, builder.ChainIndexes.Direct);
builder.create(builder.Modulators.Velocity, "DynMod1", ss, builder.ChainIndexes.Gain);
builder.create(builder.Modulators.Velocity, "DynMod2", ss, builder.ChainIndexes.Gain);
builder.flush();

// Context: Two velocity modulators are shaped so that one fades out while the
// other fades in, maintaining constant perceived loudness across the range.
const var NUM_LAYERS = 2;
const var layers = [];

for (i = 0; i < NUM_LAYERS; i++)
    layers[i] = Synth.getTableProcessor("DynMod" + (i + 1));

// Layer 0: fade out (concave curve = 0.25)
layers[0].reset(0);
layers[0].setTablePoint(0, 0, 0, 1, 1);
layers[0].setTablePoint(0, 1, 1, 0, 0.25);

// Layer 1: fade in (convex curve = 0.75)
layers[1].reset(0);
layers[1].setTablePoint(0, 0, 0, 0, 1);
layers[1].setTablePoint(0, 1, 1, 1, 0.75);
// test
/compile

# Verify
/expect layers[0].getTable(0).getTableValueNormalised(0.0) is 1.0
/expect layers[0].getTable(0).getTableValueNormalised(1.0) is 0.0
/expect layers[1].getTable(0).getTableValueNormalised(1.0) is 1.0
/exit
// end test
