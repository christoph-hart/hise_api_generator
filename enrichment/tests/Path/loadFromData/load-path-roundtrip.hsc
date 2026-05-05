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
const var p = Content.createPath();
p.startNewSubPath(0.0, 0.0);
p.lineTo(1.0, 0.0);
p.lineTo(0.5, 1.0);
p.closeSubPath();

var encoded = p.toBase64();

const var p2 = Content.createPath();
p2.loadFromData(encoded);
// test
/compile

# Verify
/expect p2.getLength() > 0 is true
/expect p.toBase64() == p2.toBase64() is true
/exit
// end test
