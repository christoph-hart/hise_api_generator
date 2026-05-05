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
// Context: When a path is reused across multiple paint calls with
// different geometry each time, a helper function that clears and
// re-anchors avoids repeating the boilerplate.

const var arcPath = Content.createPath();

inline function clearPathWithNormBounds(p)
{
    p.clear();
    p.startNewSubPath(0.0, 0.0);
    p.startNewSubPath(1.0, 1.0);
}

// Reuse the same path object efficiently
clearPathWithNormBounds(arcPath);
arcPath.addArc([0.0, 0.0, 1.0, 1.0], -2.5, 2.5);

var helperBounds = arcPath.getBounds(1.0);
// test
/compile

# Verify
/expect arcPath.getLength() > 0 is true
/expect Math.abs(helperBounds[0]) < 0.01 is true
/expect Math.abs(helperBounds[2] - 1.0) < 0.01 is true
/exit
// end test
