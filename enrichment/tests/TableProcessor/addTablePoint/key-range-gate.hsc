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
// Title: Building a key range gate on a KeyModulator table
const var builder = Synth.createBuilder();
builder.clear();
var ss = builder.create(builder.SoundGenerators.SineSynth, "TestSynth", 0, builder.ChainIndexes.Direct);
builder.create(builder.Modulators.Velocity, "KeyMod", ss, builder.ChainIndexes.Gain);
builder.flush();

// Context: Creates a bandpass-shaped curve so a sound only plays within a
// specific MIDI key range. The table acts as a gate: 0 outside the range, 1 inside.
const var tp = Synth.getTableProcessor("KeyMod");
const var LOW_KEY = 36;
const var HIGH_KEY = 72;

// Always reset before building a new shape
tp.reset(0);

// Build a trapezoidal gate: silent -> full -> full -> silent
tp.addTablePoint(0, LOW_KEY / 127, 0.0);
tp.addTablePoint(0, LOW_KEY / 127, 1.0);
tp.addTablePoint(0, HIGH_KEY / 127, 1.0);
tp.addTablePoint(0, HIGH_KEY / 127, 0.0);

// Fix the last endpoint (index 5 after reset's 2 defaults + 4 added)
tp.setTablePoint(0, 5, 1.0, 0.0, 0.5);
// test
/compile

# Verify
/expect tp.getTable(0).getTableValueNormalised(0.4) is 1.0
/expect tp.getTable(0).getTableValueNormalised(0.1) is 0.0
/exit
// end test
