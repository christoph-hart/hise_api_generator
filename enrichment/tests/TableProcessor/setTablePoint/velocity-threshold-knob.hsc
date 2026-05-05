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
// Title: Adjusting a velocity threshold at runtime
const var builder = Synth.createBuilder();
builder.clear();
var ss = builder.create(builder.SoundGenerators.SineSynth, "TestSynth", 0, builder.ChainIndexes.Direct);
builder.create(builder.Modulators.Velocity, "AttackVelocity", ss, builder.ChainIndexes.Gain);
builder.flush();

// Context: A knob controls where a velocity modulator's table transitions from
// 0 to 1, creating a threshold effect. Only interior points are moved.
const var velocityMod = Synth.getModulator("AttackVelocity");
const var tp = velocityMod.asTableProcessor();

// Build a threshold shape with 5 points so the two transition
// points (indices 2 and 3) stay interior and their x can be moved.
// Edge points (first and last index) ignore x in setTablePoint.
tp.reset(0);
tp.setTablePoint(0, 0, 0, 0, 0.5);        // edge start: silent
tp.addTablePoint(0, 0.3, 0.0);              // index 2: pre-threshold
tp.addTablePoint(0, 0.4, 1.0);              // index 3: post-threshold
tp.addTablePoint(0, 0.95, 1.0);             // index 4: new edge end
tp.setTablePoint(0, 4, 1.0, 1.0, 0.5);     // edge end: full volume

inline function onThresholdChanged(component, value)
{
    // Move the transition region based on the threshold knob (0-127)
    tp.setTablePoint(0, 2, (value - 1) / 127, 0.01, 0);
    tp.setTablePoint(0, 3, value / 127, 1, 0);
}
// test
onThresholdChanged(undefined, 64);
/compile

# Verify
/expect tp.getTable(0).getTableValueNormalised(80 / 127) > 0.9 is true
/exit
// end test
