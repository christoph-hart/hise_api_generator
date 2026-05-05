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
// Title: Build a MIDI note-to-channel routing table
// Context: A multi-channel instrument maps each MIDI note to a channel
// index. Unassigned notes remain at -1 (the default after clear).

const var NUM_CHANNELS = 4;
const var channelKeys = [36, 38, 42, 46]; // kick, snare, hihat, open hihat

const var noteToChannel = Engine.createMidiList();

// Populate the routing table
for (i = 0; i < NUM_CHANNELS; i++)
    noteToChannel.setValue(channelKeys[i], i);

// Look up channel for incoming note
Console.print(noteToChannel.getValue(36));  // 0 (first channel)
Console.print(noteToChannel.getValue(60));  // -1 (unassigned)
// test
/compile

# Verify
/expect-logs ["0", "-1"]
/exit
// end test
