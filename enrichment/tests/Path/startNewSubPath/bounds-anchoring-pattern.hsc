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
// Context: The most frequent use of startNewSubPath is NOT to begin
// visible drawing, but to anchor the path's bounding box to a known
// coordinate range. When a path will be rendered via
// g.drawPath(path, targetArea), the path is scaled from its bounding
// box to the target area. Without anchoring, an arc or partial shape
// has a bounding box that only covers its actual geometry, causing
// misalignment when scaled.

var p = Content.createPath();

// Anchor to unit square - these points are invisible but define bounds
p.startNewSubPath(0.0, 0.0);
p.startNewSubPath(1.0, 1.0);

// Now add actual geometry
p.addArc([0.0, 0.0, 1.0, 1.0], -2.4, 2.4);

// The path's bounds are [0, 0, 1, 1] regardless of the arc extent
var bounds = p.getBounds(1.0);
// test
/compile

# Verify
/expect Math.abs(bounds[0]) < 0.01 is true
/expect Math.abs(bounds[1]) < 0.01 is true
/expect Math.abs(bounds[2] - 1.0) < 0.01 is true
/expect Math.abs(bounds[3] - 1.0) < 0.01 is true
/exit
// end test
