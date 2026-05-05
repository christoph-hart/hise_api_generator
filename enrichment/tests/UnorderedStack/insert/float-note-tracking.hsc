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
// Context: A granular effect tracks active notes and randomly selects
// from them to spawn new grains. insert() provides set semantics
// (no duplicates), and bracket access picks a random element.

const var activeNotes = Engine.createUnorderedStack();

// onNoteOn / onNoteOff
inline function handleNote(noteNumber, velocity)
{
    if (velocity != 0)
        activeNotes.insert(noteNumber);
    else
        activeNotes.remove(noteNumber);
}

// Timer callback: pick a random held note for grain spawning
inline function spawnGrain()
{
    local count = activeNotes.size();

    if (count > 0)
    {
        // Bracket access reads from the float array by index
        local randomNote = activeNotes[Math.randInt(0, count)];
        Console.print("Spawning grain at note: " + randomNote);
    }
}
// test
handleNote(60, 100);
handleNote(64, 100);
handleNote(67, 100);
handleNote(64, 0);
/compile

# Verify
/expect activeNotes.size() is 2
/expect activeNotes.contains(60.0) is 1
/expect activeNotes.contains(64.0) is 0
/expect activeNotes.contains(67.0) is 1
/exit
// end test
