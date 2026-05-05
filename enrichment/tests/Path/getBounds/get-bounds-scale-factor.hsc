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
// Title: Using getBounds to position path rendering in a paint routine
// Context: When a path is built in an arbitrary coordinate space
// (e.g., arc paths from addArc), getBounds returns the actual area
// the path occupies. Multiplying by a scale factor maps from the
// path's internal coordinates to pixel dimensions for rendering.

const var arcPath = Content.createPath();
arcPath.startNewSubPath(0.0, 0.0);
arcPath.startNewSubPath(1.0, 1.0);
arcPath.addArc([0.0, 0.0, 1.0, 1.0], -2.4, 2.4);

var scaledBounds = arcPath.getBounds(200.0);
Console.print("Bounds: " + scaledBounds[0] + ", " + scaledBounds[1] +
              ", " + scaledBounds[2] + ", " + scaledBounds[3]);
// test
/compile

# Verify
/expect scaledBounds.length is 4
/expect scaledBounds[2] > 0 is true
/expect scaledBounds[3] > 0 is true
/exit
// end test
