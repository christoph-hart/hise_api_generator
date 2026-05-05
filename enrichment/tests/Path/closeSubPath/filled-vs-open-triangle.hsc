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
// Title: Filled triangle vs open triangle
// Context: closeSubPath is required for shapes that need to be filled
// with Graphics.fillPath. Without it, fillPath still works but the
// path is implicitly closed by a straight line from the last point
// to the start. Explicitly closing is good practice and makes the
// intent clear.

const var filled = Content.createPath();
filled.startNewSubPath(0.0, 1.0);
filled.lineTo(0.5, 0.0);
filled.lineTo(1.0, 1.0);
filled.closeSubPath();  // explicit close for fillPath

const var open = Content.createPath();
open.startNewSubPath(0.0, 1.0);
open.lineTo(0.5, 0.0);
open.lineTo(1.0, 1.0);
// No closeSubPath - used with drawPath for an open "V" shape
// test
/compile

# Verify
/expect filled.getLength() > open.getLength() is true
/expect filled.contains([0.5, 0.8]) is true
/exit
// end test
