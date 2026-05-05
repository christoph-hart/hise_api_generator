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
// Title: Configuring module parameters after creation
const var b = Synth.createBuilder();
b.clear();
var synthIdx = b.create(b.SoundGenerators.SineSynth, "AttrSine", 0, b.ChainIndexes.Direct);
b.setAttributes(synthIdx, {"OctaveTranspose": 3, "SemiTones": 7});
b.flush();

const var sine = Synth.getChildSynth("AttrSine");
Console.print(sine.getAttribute(sine.OctaveTranspose));
Console.print(sine.getAttribute(sine.SemiTones));
// test
/compile

# Verify
/expect-logs ["3", "7"]
/exit
// end test
