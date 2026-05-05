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
// Title: Reset tracking state when articulation is muted
// Context: Clearing stored velocities and timing data prevents stale
// state from carrying over when the user mutes and unmutes an articulation.

const var velocities = Engine.createMidiList();
const var noteLengths = Engine.createMidiList();

velocities.fill(64);
noteLengths.fill(100);

// On mute toggle:
velocities.clear();
noteLengths.clear();
// test
/compile

# Verify
/expect velocities.isEmpty() is 1
/expect noteLengths.isEmpty() is 1
/exit
// end test
