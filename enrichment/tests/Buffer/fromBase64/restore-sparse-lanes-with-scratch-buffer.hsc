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
// Title: Restore sparse lane state with one reusable scratch buffer
// Context: Import routines decode many payloads, so they reuse one temp Buffer and handle "EMPTY" entries explicitly.

const var NUM_STEPS = 16;

const var source = Buffer.create(NUM_STEPS);
source[2] = 1.0;

const var encodedLanes = ["EMPTY", source.toBase64(), "EMPTY"];
const var decodedLanes = [];
const var scratch = Buffer.create(NUM_STEPS);

for (entry in encodedLanes)
{
    if (entry == "EMPTY")
    {
        decodedLanes.push(Buffer.create(NUM_STEPS));
        continue;
    }

    local ok = scratch.fromBase64(entry);

    if (!ok)
    {
        decodedLanes.push(Buffer.create(NUM_STEPS));
        continue;
    }

    local lane = Buffer.create(NUM_STEPS);
    scratch >> lane;
    decodedLanes.push(lane);
}
// test
/compile

# Verify
/expect decodedLanes.length is 3
/expect decodedLanes[0].getMagnitude(0, NUM_STEPS) is 0
/expect decodedLanes[1][2] is 1
/expect decodedLanes[2].length is 16
/exit
// end test
