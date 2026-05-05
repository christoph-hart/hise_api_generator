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
// Title: Closed segments for per-section envelope highlighting
// Context: Envelope editors create separate closed sub-paths for
// each envelope segment (attack, decay, sustain, release) so that
// individual segments can be highlighted on hover by filling them
// with a translucent colour.

// Attack segment (filled area under the curve)
var attackPath = Content.createPath();
attackPath.startNewSubPath(0.0, 1.0);   // bottom-left
attackPath.quadraticTo(0.1, 0.2, 0.3, 0.0);  // curve to peak
attackPath.lineTo(0.3, 1.0);            // down to baseline
attackPath.closeSubPath();               // close for fill
// test
/compile

# Verify
/expect attackPath.getLength() > 0 is true
/expect attackPath.contains([0.15, 0.8]) is true
/exit
// end test
