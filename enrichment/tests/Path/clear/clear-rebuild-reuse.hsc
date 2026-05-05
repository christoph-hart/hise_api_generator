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
// Title: Clearing and rebuilding a path with new geometry
// Context: When a path's geometry changes (e.g., following a
// modulation value), clearing and rebuilding is more efficient
// than creating a new Path each time. The clear + anchor + rebuild
// pattern appears frequently in timer-driven UI updates.

const var arcPath = Content.createPath();

// Build initial geometry
arcPath.startNewSubPath(0.0, 0.0);
arcPath.startNewSubPath(1.0, 1.0);
arcPath.addArc([0, 0, 1, 1], -2.4, 0.0);
var lengthBefore = arcPath.getLength();

// Clear and rebuild with different geometry
arcPath.clear();
var lengthAfterClear = arcPath.getLength();

arcPath.startNewSubPath(0.0, 0.0);
arcPath.startNewSubPath(1.0, 1.0);
arcPath.addArc([0, 0, 1, 1], -2.4, 2.4);
var lengthAfterRebuild = arcPath.getLength();
// test
/compile

# Verify
/expect lengthAfterClear is 0
/expect lengthAfterRebuild > lengthBefore is true
/exit
// end test
