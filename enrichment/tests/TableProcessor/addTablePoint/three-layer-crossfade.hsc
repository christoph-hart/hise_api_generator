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
// Title: 3-layer crossfade with interior points
const var builder = Synth.createBuilder();
builder.clear();
var ss = builder.create(builder.SoundGenerators.SineSynth, "TestSynth", 0, builder.ChainIndexes.Direct);
builder.create(builder.Modulators.Velocity, "DynMod2", ss, builder.ChainIndexes.Gain);
builder.flush();

// Context: When crossfading more than 2 layers, interior points define each
// layer's active region. Each layer rises and falls within its segment.
const var mid = Synth.getTableProcessor("DynMod2");

mid.reset(0);

// Start at zero
mid.setTablePoint(0, 0, 0, 0, 1);

// Add an interior peak -- addTablePoint uses default curve 0.5
mid.addTablePoint(0, 1, 1);

// Shape the peak position and fade slopes
mid.setTablePoint(0, 1, 0.5, 1, 0.75);   // rise to peak at midpoint
mid.setTablePoint(0, 2, 1, 0, 0.25);       // fall to zero at end
// test
/compile

# Verify
/expect mid.getTable(0).getTableValueNormalised(0.0) is 0.0
/expect mid.getTable(0).getTableValueNormalised(0.5) > 0.99 is true
/expect mid.getTable(0).getTableValueNormalised(1.0) is 0.0
/exit
// end test
