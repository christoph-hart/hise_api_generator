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
// Title: Loop-based channel strip construction
// Context: Building N identical processing channels in a loop. Each channel
// gets a container synth, a sound generator, MIDI processors, and effects.
// This is the Builder's primary advantage over manual tree construction.

const var NUM_CHANNELS = 4;
const var b = Synth.createBuilder();

inline function buildChannel(channelIndex)
{
    // Container for this channel (Direct = add as sound generator)
    local container = b.create(b.SoundGenerators.SynthChain,
        "Container " + (channelIndex + 1), 0, b.ChainIndexes.Direct);

    // Sound generator inside the container
    local synth = b.create(b.SoundGenerators.SilentSynth,
        "Channel " + (channelIndex + 1), container, b.ChainIndexes.Direct);

    // MIDI processor on the synth
    local muter = b.create(b.MidiProcessors.MidiMuter,
        "Muter " + (channelIndex + 1), synth, b.ChainIndexes.Midi);

    // Effects on the container
    local eq = b.create(b.Effects.HardcodedMasterFX,
        "EQ " + (channelIndex + 1), container, b.ChainIndexes.FX);

    local gain = b.create(b.Effects.SimpleGain,
        "Gain " + (channelIndex + 1), container, b.ChainIndexes.FX);
}

b.clear();

for (i = 0; i < NUM_CHANNELS; i++)
    buildChannel(i);

b.flush();

// After building, retrieve modules by name:
Console.print(Synth.getChildSynth("Channel 1").getId());
Console.print(Synth.getEffect("Gain 1").getId());
Console.print(Synth.getChildSynth("Container 4").getId());
// test
/compile

# Verify
/expect-logs ["Channel 1", "Gain 1", "Container 4"]
/exit
// end test
