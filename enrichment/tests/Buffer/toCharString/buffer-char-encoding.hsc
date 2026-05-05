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
const var b = Buffer.create(32);
const var encoded = b.toCharString(16, [-1.0, 1.0]);
// test
/compile

# Verify
/expect encoded.length is 32
/exit
// end test
