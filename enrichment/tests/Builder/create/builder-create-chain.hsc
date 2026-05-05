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
// Title: Creating a synth with effect chain
const var b = Synth.createBuilder();
b.clear();
var synthIdx = b.create(b.SoundGenerators.SineSynth, "MySine", 0, b.ChainIndexes.Direct);
var gainIdx = b.create(b.Effects.SimpleGain, "MyGain", synthIdx, b.ChainIndexes.FX);
b.setAttributes(gainIdx, {"Gain": -6.0});
b.flush();

Console.print(Synth.getChildSynth("MySine").getId());
Console.print(Synth.getEffect("MyGain").getAttribute(0));
// test
/compile

# Verify
/expect-logs ["MySine", "-6"]
/exit
// end test
