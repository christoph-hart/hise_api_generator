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
// Title: Initialize a key-state display to "all keys up"
// Context: A visual keyboard panel uses 0 for "key up" and 1 for "key down."
// fill(0) establishes the initial state where no keys are pressed.

const var noteStates = Engine.createMidiList();
noteStates.fill(0);

// Later, in onNoteOn / onNoteOff:
// noteStates.setValue(Message.getNoteNumber(), 1);  // key down
// noteStates.setValue(Message.getNoteNumber(), 0);  // key up
// test
/compile

# Verify
/expect noteStates.getValue(0) is 0
/expect noteStates.getValue(127) is 0
/expect noteStates.getNumSetValues() is 128
/exit
// end test
