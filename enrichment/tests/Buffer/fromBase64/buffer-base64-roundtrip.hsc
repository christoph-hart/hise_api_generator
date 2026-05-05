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
const var source = Buffer.create(4);
source[0] = 0.1; source[1] = 0.2; source[2] = 0.3; source[3] = 0.4;
const var encoded = source.toBase64();

const var target = Buffer.create(1);
const var ok = target.fromBase64(encoded);
// test
/compile

# Verify
/expect ok is 1
/expect target.length is 4
/exit
// end test
