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
// Context: Preset models often store many lanes; writing "EMPTY" for silent lanes reduces payload size.

const var NUM_LANES = 4;
const var NUM_STEPS = 16;

inline function encodeLane(stepBuffer)
{
    local range = stepBuffer.getPeakRange(0, NUM_STEPS);
    local isEmpty = range[0] == 0.0 && range[1] == 0.0;
    return isEmpty ? "EMPTY" : stepBuffer.toBase64();
}

const var laneBuffers = [];

for (i = 0; i < NUM_LANES; i++)
    laneBuffers.push(Buffer.create(NUM_STEPS));

laneBuffers[1][2] = 1.0;
laneBuffers[3][8] = 0.4;

const var state = [];

for (b in laneBuffers)
    state.push(encodeLane(b));

Console.print(trace(state)); // ["EMPTY", "Buffer...", "EMPTY", "Buffer..."]
// test
/compile

# Verify
/expect state[0] is "EMPTY"
/expect state[1].substring(0, 6) is "Buffer"
/expect state[2] is "EMPTY"
/expect state[3].substring(0, 6) is "Buffer"
/exit
// end test
