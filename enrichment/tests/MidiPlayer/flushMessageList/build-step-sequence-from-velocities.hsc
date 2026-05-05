// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add MidiPlayer as "MidiPlayer1"
/exit

/script
/callback onInit
// end setup
// Title: Programmatically building a step sequence from slider data
// Context: Convert a velocity array (from a SliderPack or UI data) into
// MIDI note-on/note-off pairs and flush them into the current sequence

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.setUseTimestampInTicks(true);
mp.create(4, 4, 1);

const var NOTE_NUMBER = 64;
const var NUM_STEPS = 16;
const var STEP_SIZE = mp.getTicksPerQuarter() / 4; // 16th note = 240 ticks

// Example velocity values (0.0 = silent, >0 = active)
const var velocities = [1.0, 0.0, 0.5, 0.0, 1.0, 0.0, 0.75, 0.0,
                        1.0, 0.0, 0.5, 0.0, 1.0, 0.0, 0.75, 0.0];

var noteList = [];
noteList.reserve(NUM_STEPS * 2);

for (i = 0; i < NUM_STEPS; i++)
{
    if (velocities[i] > 0.0)
    {
        var on = Engine.createMessageHolder();
        var off = Engine.createMessageHolder();

        on.setType(on.NoteOn);
        off.setType(on.NoteOff);

        on.setChannel(1);
        off.setChannel(1);

        on.setNoteNumber(NOTE_NUMBER);
        off.setNoteNumber(NOTE_NUMBER);

        on.setVelocity(parseInt(velocities[i] * 127));

        on.setTimestamp(i * STEP_SIZE);
        off.setTimestamp(i * STEP_SIZE + STEP_SIZE - 1);

        noteList.push(on);
        noteList.push(off);
    }
}

mp.flushMessageList(noteList);
// test
/compile

# Verify
/expect mp.getEventList().length is 16
/exit
// end test
