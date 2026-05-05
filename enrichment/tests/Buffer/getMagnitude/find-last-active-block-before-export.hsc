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
// Context: Export code scans fixed windows to remove trailing silence while keeping release tails.

const var TOTAL_SAMPLES = 4096;
const var ANALYSIS_BLOCK_SIZE = 256;
const var SILENCE_THRESHOLD = 0.00001;

const var left = Buffer.create(TOTAL_SAMPLES);
const var right = Buffer.create(TOTAL_SAMPLES);

left[2200] = 0.4;
right[2201] = -0.3;

local lastActiveSample = 0;

for (i = 0; i < TOTAL_SAMPLES - ANALYSIS_BLOCK_SIZE; i += ANALYSIS_BLOCK_SIZE)
{
    local l = left.getMagnitude(i, ANALYSIS_BLOCK_SIZE);
    local r = right.getMagnitude(i, ANALYSIS_BLOCK_SIZE);
    local g = Math.max(l, r);

    if (g > SILENCE_THRESHOLD)
        lastActiveSample = i + ANALYSIS_BLOCK_SIZE;
}

Console.print(lastActiveSample); // 2304
// test
/compile

# Verify
/expect lastActiveSample is 2304
/expect left.getMagnitude(2048, ANALYSIS_BLOCK_SIZE) is 0.4
/expect right.getMagnitude(2304, ANALYSIS_BLOCK_SIZE) is 0
/exit
// end test
