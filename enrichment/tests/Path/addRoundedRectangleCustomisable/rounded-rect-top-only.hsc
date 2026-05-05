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
p.addRoundedRectangleCustomisable([0, 0, 200, 100], [10.0, 10.0], [true, true, false, false]);
// test
/compile

# Verify
/expect p.contains([100, 50]) is true
/expect Math.abs(p.getBounds(1.0)[2] - 200.0) < 0.5 is true
/exit
// end test
