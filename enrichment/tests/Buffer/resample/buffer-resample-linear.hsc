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
const var b = Buffer.create(16);
b[4] = 1.0;
const var half = b.resample(2.0, "Linear", false);
// test
/compile

# Verify
/expect half.length is 8
/expect half[2] is 1
/exit
// end test
