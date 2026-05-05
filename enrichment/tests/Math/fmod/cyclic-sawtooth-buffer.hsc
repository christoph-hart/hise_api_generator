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
// Context: Math.fmod wraps a linearly increasing value into a
// repeating 0-1 cycle, useful for generating waveforms or
// cycling through animation frames.

const var BUFFER_SIZE = 2048;
const var bf = Buffer.create(BUFFER_SIZE);

for (i = 0; i < BUFFER_SIZE; i++)
{
    // Sawtooth: ramp from -1 to 1, repeating
    bf[i] = 2.0 * Math.fmod((i + BUFFER_SIZE / 2) / 2048.0, 1.0) - 1.0;
}
// test
/compile

# Verify
/expect bf.length is 2048
/expect bf[0] is 0.0
/expect bf[512] is 0.5
/exit
// end test
