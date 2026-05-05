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
// Title: Slice shares storage with the source buffer
const var source = Buffer.create(6);
source[0] = 1.0; source[1] = 2.0; source[2] = 3.0;
source[3] = 4.0; source[4] = 5.0; source[5] = 6.0;

const var slice = source.getSlice(2, 2);
slice[0] = 99.0;
// test
/compile

# Verify
/expect slice.length is 2
/expect source[2] is 99
/exit
// end test
