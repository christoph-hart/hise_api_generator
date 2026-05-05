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
// Title: Transport button icons (play, stop)
// Context: Media transport controls are typically built as simple
// path shapes rendered inside toggle button LAF callbacks.

const var playIcon = Content.createPath();
playIcon.startNewSubPath(0.0, 0.0);
playIcon.lineTo(0.0, 1.0);
playIcon.lineTo(1.0, 0.5);
playIcon.closeSubPath();

const var stopIcon = Content.createPath();
stopIcon.startNewSubPath(0.0, 0.0);
stopIcon.lineTo(0.0, 1.0);
stopIcon.lineTo(1.0, 1.0);
stopIcon.lineTo(1.0, 0.0);
stopIcon.closeSubPath();
// test
/compile

# Verify
/expect playIcon.contains([0.3, 0.5]) is true
/expect stopIcon.contains([0.5, 0.5]) is true
/exit
// end test
