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
// Title: Extracting a Table data object for direct evaluation
const var builder = Synth.createBuilder();
builder.clear();
var ss = builder.create(builder.SoundGenerators.SineSynth, "TestSynth", 0, builder.ChainIndexes.Direct);
builder.create(builder.Modulators.Velocity, "VelocityMod", ss, builder.ChainIndexes.Gain);
builder.flush();

const var tp = Synth.getTableProcessor("VelocityMod");
const var table = tp.getTable(0);

// Add a midpoint and read back the interpolated curve
table.addTablePoint(0.5, 0.8);
var curveValue = table.getTableValueNormalised(0.25);
Console.print("Interpolated value at 0.25: " + curveValue);
// test
/compile

# Verify
/expect Math.abs(table.getTableValueNormalised(0.5) - 0.8) < 0.01 is true
/exit
// end test
