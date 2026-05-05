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

// Full donut ring background
p.addPieSegment([0, 0, 100, 100], -2.5, 2.5, 0.7);

// Active value arc overlay
const var valuePath = Content.createPath();
valuePath.addPieSegment([0, 0, 100, 100], -2.5, 0.5, 0.7);
// test
/compile

# Verify
/expect p.getLength() > valuePath.getLength() is true
/expect p.getLength() > 0 is true
/exit
// end test
