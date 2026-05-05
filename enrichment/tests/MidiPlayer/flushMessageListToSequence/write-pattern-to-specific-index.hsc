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
// Context: In a multi-pattern sequencer, write programmatically generated
// notes to a specific pattern index. This avoids switching the active
// sequence just to write data.

const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.setUseTimestampInTicks(true);
mp.clearAllSequences();
mp.create(4, 4, 1);
mp.create(4, 4, 1);

const var STEP_SIZE = mp.getTicksPerQuarter() / 4; // 16th note grid

inline function writePatternData(patternIndex, noteNumber, velocityArray)
{
    local notes = [];
    notes.reserve(velocityArray.length * 2);

    for (i = 0; i < velocityArray.length; i++)
    {
        if (velocityArray[i] == 0.0)
            continue;

        local on = Engine.createMessageHolder();
        local off = Engine.createMessageHolder();

        on.setType(on.NoteOn);
        off.setType(on.NoteOff);
        on.setChannel(1);
        off.setChannel(1);
        on.setNoteNumber(noteNumber);
        off.setNoteNumber(noteNumber);
        on.setVelocity(parseInt(velocityArray[i] * 127));
        on.setTimestamp(i * STEP_SIZE);
        off.setTimestamp(i * STEP_SIZE + STEP_SIZE - 1);

        notes.push(on);
        notes.push(off);
    }

    // Write to one-based pattern index without changing the active sequence
    mp.flushMessageListToSequence(notes, patternIndex + 1);
}

// Write to pattern 2 (internal index 1 -> one-based = 2)
writePatternData(1, 60, [1.0, 0.0, 0.5, 0.0]);
// test
/compile

# Verify
/expect mp.getEventListFromSequence(2).length is 4
/exit
// end test
