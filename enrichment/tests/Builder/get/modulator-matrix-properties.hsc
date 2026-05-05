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
// Title: Modulator interface for MatrixModulator configuration
// Context: When building a modulation matrix, get() with InterfaceTypes.Modulator
// returns a reference that supports setMatrixProperties() for configuring the
// modulator's input/output ranges and text converter.

const var b = Synth.createBuilder();

var groupIdx = b.create(b.SoundGenerators.SynthGroup,
    "OSC1", 0, b.ChainIndexes.Direct);

// Create a MatrixModulator on the gain chain
var modIdx = b.create(b.Modulators.MatrixModulator,
    "OSC1 Gain", groupIdx, b.ChainIndexes.Gain);

// Get the Modulator interface to configure matrix properties
var mod = b.get(modIdx, b.InterfaceTypes.Modulator);
mod.setMatrixProperties({
    "InputRange": { "min": -100.0, "max": 6.0, "middlePosition": 0.0 },
    "OutputRange": { "min": 0.0, "max": 2.0 },
    "TextConverter": "Decibels"
});

b.flush();

Console.print(Synth.getChildSynth("OSC1").getId());
Console.print(Synth.getModulator("OSC1 Gain").getId());
// test
/compile

# Verify
/expect-logs ["OSC1", "OSC1 Gain"]
/exit
// end test
