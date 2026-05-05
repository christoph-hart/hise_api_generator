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
// Title: Save a custom MIDI mapping to a user preset
// Context: A plugin allows users to remap which MIDI note triggers each
// sound. The mapping is stored in a MidiList and serialized to Base64
// for inclusion in user preset data.

const var noteToChannel = Engine.createMidiList();

// Simulate a user-configured mapping
noteToChannel.setValue(36, 0);
noteToChannel.setValue(38, 1);
noteToChannel.setValue(42, 2);

// Save the mapping as part of custom preset data
inline function getPresetData()
{
    local data = {};
    data.MidiMapping = noteToChannel.getBase64String();
    data.Version = 2;
    return data;
}

const var preset = getPresetData();
Console.print(isDefined(preset.MidiMapping));
Console.print(typeof preset.MidiMapping == "string");
// test
/compile

# Verify
/expect-logs ["1", "1"]
/exit
// end test
