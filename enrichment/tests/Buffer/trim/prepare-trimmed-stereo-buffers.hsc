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
// Title: Prepare trimmed stereo buffers for file writing
// Context: After tail detection, export paths trim both channels to the same final length.

const var TOTAL_SAMPLES = 4096;
const var ACTIVE_SAMPLES = 2816;

const var left = Buffer.create(TOTAL_SAMPLES);
const var right = Buffer.create(TOTAL_SAMPLES);

left[ACTIVE_SAMPLES - 1] = 0.2;
right[ACTIVE_SAMPLES - 1] = 0.2;

local samplesToTrimAtEnd = TOTAL_SAMPLES - ACTIVE_SAMPLES;

const var channelsToWrite = [
    left.trim(0, samplesToTrimAtEnd),
    right.trim(0, samplesToTrimAtEnd)
];

Console.print(channelsToWrite[0].length); // 2816
Console.print(channelsToWrite[1].length); // 2816
// test
/compile

# Verify
/expect channelsToWrite[0].length is 2816
/expect channelsToWrite[1].length is 2816
/expect left.length is 4096
/exit
// end test
