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
// Title: Smooth short spikes with a median filter
const var b = Buffer.create(8);
b[0] = 0.0; b[1] = 0.0; b[2] = 1.0; b[3] = 0.0;
b[4] = 0.0; b[5] = 1.0; b[6] = 0.0; b[7] = 0.0;

const var filtered = b.applyMedianFilter(3);
// test
/compile

# Verify
/expect filtered.length is 8
/expect filtered[2] is 0
/expect b[2] is 1
/exit
// end test
