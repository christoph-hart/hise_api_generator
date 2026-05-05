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
// Title: Bipolar knob arc (center-origin)
// Context: For parameters with a center default (like pan or bipolar
// modulation), the arc starts from 12 o'clock (angle 0) and extends
// in both directions based on the value.

const var ARC2 = 2.4;

// Simulate bipolar and unipolar paths
var isBipolar = true;
var startAngle = isBipolar ? 0.0 : -ARC2;
var valueNormalized = 0.75;

var valuePath = Content.createPath();
valuePath.startNewSubPath(0.0, 0.0);
valuePath.startNewSubPath(1.0, 1.0);

var endAngle = -ARC2 + 2.0 * ARC2 * valueNormalized;
valuePath.addArc([0.0, 0.0, 1.0, 1.0], startAngle, endAngle);
// test
/compile

# Verify
/expect valuePath.getLength() > 0 is true
/expect Math.abs(valuePath.getBounds(1.0)[2] - 1.0) < 0.01 is true
/exit
// end test
