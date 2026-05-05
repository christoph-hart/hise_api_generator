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
// Context: asBuffer(false) returns only occupied elements, ideal
// for iterating active notes without processing 128 empty slots.

const var pressedNotes = Engine.createUnorderedStack();

inline function analyzeChord()
{
    if (pressedNotes.size() < 3)
        return;

    // Iterate only the occupied elements
    local activeBuffer = pressedNotes.asBuffer(false);
    local pitchClasses = [];

    for (note in activeBuffer)
    {
        local pc = parseInt(note) % 12;
        pitchClasses.push(pc);
    }

    Console.print("Pitch classes: " + trace(pitchClasses));
}
// test
pressedNotes.insert(60.0);
pressedNotes.insert(64.0);
pressedNotes.insert(67.0);
analyzeChord();
/compile

# Verify
/expect pressedNotes.size() is 3
/expect pressedNotes.asBuffer(false).length is 3
/exit
// end test
