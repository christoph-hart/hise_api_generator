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
// Title: Selecting random items from a modulation matrix
// Context: A "randomize" button picks random source and destination
// indices for modulation routing slots.

const var NUM_SOURCES = 8;
const var NUM_DESTINATIONS = 16;

inline function randomizeSlot()
{
    // Upper bound is exclusive: randInt(0, 8) returns 0-7
    local source = Math.randInt(0, NUM_SOURCES);
    local dest = Math.randInt(0, NUM_DESTINATIONS);
    return [source, dest];
}

var slot = randomizeSlot();
Console.print(slot[0] + ", " + slot[1]);
// test
/compile

# Verify
/expect slot.length is 2
/expect slot[0] >= 0 && slot[0] < 8 is true
/expect slot[1] >= 0 && slot[1] < 16 is true
/exit
// end test
