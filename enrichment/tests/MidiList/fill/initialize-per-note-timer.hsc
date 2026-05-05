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
// Title: Initialize a per-note timer to zero
// Context: A round-robin system needs to track when each note was last
// triggered. fill(0) ensures that the first note-on for any key will
// always exceed the reset threshold (since Engine.getUptime() > 0).

const var lastTriggerTime = Engine.createMidiList();
lastTriggerTime.fill(0);

const var RESET_THRESHOLD = 3; // seconds

// In onNoteOn:
// local elapsed = Engine.getUptime() - lastTriggerTime.getValue(noteNumber);
// if (elapsed > RESET_THRESHOLD)
//     resetRoundRobin();
// lastTriggerTime.setValue(noteNumber, Engine.getUptime());
// test
/compile

# Verify
/expect lastTriggerTime.getValue(60) is 0
/expect lastTriggerTime.getNumSetValues() is 128
/exit
// end test
