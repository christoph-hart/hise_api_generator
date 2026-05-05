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
// Title: Skip empty lanes before preset serialization
// Context: Step-lane data is stored sparsely, so only lanes with real activity are serialized.

const var NUM_STEPS = 16;

inline function hasLaneActivity(stepBuffer)
{
    local range = stepBuffer.getPeakRange(0, NUM_STEPS);
    return range[0] != 0.0 || range[1] != 0.0;
}

const var laneA = Buffer.create(NUM_STEPS);
const var laneB = Buffer.create(NUM_STEPS);

laneB[3] = 0.75;

const var payload = [];
payload.push(hasLaneActivity(laneA) ? laneA.toBase64() : "EMPTY");
payload.push(hasLaneActivity(laneB) ? laneB.toBase64() : "EMPTY");

Console.print(payload[0]); // EMPTY
Console.print(payload[1].substring(0, 6)); // Buffer
// test
/compile

# Verify
/expect payload[0] is "EMPTY"
/expect payload[1].substring(0, 6) is "Buffer"
/expect hasLaneActivity(laneA) is false
/expect hasLaneActivity(laneB) is true
/exit
// end test
