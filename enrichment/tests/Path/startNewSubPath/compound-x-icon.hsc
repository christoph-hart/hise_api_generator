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
// Context: startNewSubPath creates a new disconnected segment within
// the same path. This builds compound shapes like an X (close) icon
// from two separate line segments.

const var closeIcon = Content.createPath();
closeIcon.startNewSubPath(0.0, 0.0);
closeIcon.lineTo(1.0, 1.0);
closeIcon.startNewSubPath(1.0, 0.0);
closeIcon.lineTo(0.0, 1.0);
// test
/compile

# Verify
/expect closeIcon.getLength() > 2.0 is true
/expect Math.abs(closeIcon.getBounds(1.0)[2] - 1.0) < 0.01 is true
/exit
// end test
