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
// Context: Passing a non-empty dotData array creates dashed stroke
// geometry. This produces tick-mark or segmented ring effects around
// rotary controls.

const var p = Content.createPath();
p.startNewSubPath(0.0, 0.0);
p.startNewSubPath(1.0, 1.0);
p.addArc([0.0, 0.0, 1.0, 1.0], -2.5, 2.5);

// Dashed stroke: 3% dash, 4% gap (in normalized path coordinates)
var dashed = p.createStrokedPath(0.005, [0.03, 0.04]);
// test
/compile

# Verify
/expect dashed.getLength() > p.getLength() is true
/expect dashed.getBounds(1.0)[3] > 0 is true
/exit
// end test
