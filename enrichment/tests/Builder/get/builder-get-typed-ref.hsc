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
const var b = Synth.createBuilder();
b.clear();
var synthIdx = b.create(b.SoundGenerators.SineSynth, "TestSine", 0, b.ChainIndexes.Direct);
var gainIdx = b.create(b.Effects.SimpleGain, "TestGain", synthIdx, b.ChainIndexes.FX);
b.flush();

var synth = b.get(synthIdx, b.InterfaceTypes.ChildSynth);
var gain = b.get(gainIdx, b.InterfaceTypes.Effect);
Console.print(synth.getId());
Console.print(gain.getId());
// test
/compile

# Verify
/expect-logs ["TestSine", "TestGain"]
/exit
// end test
