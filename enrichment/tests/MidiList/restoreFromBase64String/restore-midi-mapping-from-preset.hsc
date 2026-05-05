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
// Context: When loading a user preset, the serialized MidiList is
// decoded and applied to restore the user's custom MIDI mapping.

const var noteToChannel = Engine.createMidiList();

// Simulate saving a mapping
noteToChannel.setValue(36, 0);
noteToChannel.setValue(38, 1);
noteToChannel.setValue(42, 2);
const var saved = noteToChannel.getBase64String();

// Simulate loading from preset data
noteToChannel.clear();

inline function loadPresetData(data)
{
    if (isDefined(data.MidiMapping))
        noteToChannel.restoreFromBase64String(data.MidiMapping);
}

loadPresetData({"MidiMapping": saved});

Console.print(noteToChannel.getValue(36));
Console.print(noteToChannel.getValue(38));
Console.print(noteToChannel.getValue(42));
Console.print(noteToChannel.getValue(60));
// test
/compile

# Verify
/expect-logs ["0", "1", "2", "-1"]
/exit
// end test
