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
// Title: Thick arc converted to outline for draw + fill combination
// Context: Creating a thick stroked path, then both filling and
// outlining it, produces a solid arc band with a visible border.

var arcPath = Content.createPath();
arcPath.startNewSubPath(0.0, 0.0);
arcPath.startNewSubPath(1.0, 1.0);
arcPath.addArc([0, 0, 1.0, 1.0], -2.3, 2.3 * 2 * 0.7);

var thick = arcPath.createStrokedPath(0.22, []);
// test
/compile

# Verify
/expect thick.getLength() > arcPath.getLength() is true
/expect thick.getBounds(1.0)[3] > arcPath.getBounds(1.0)[3] is true
/exit
// end test
