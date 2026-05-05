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
// Title: Envelope curve segment with adjustable curvature
// Context: AHDSR envelope editors use quadraticTo to draw curved
// attack, decay, and release segments. The control point position
// is interpolated between start and end based on a curve parameter
// (0.0 = linear, approaching 1.0 = exponential).

const var p = Content.createPath();
var x = 0.0;
var y = 1.0;  // start at bottom
var cx = 0.0;
var cy = 1.0;

p.startNewSubPath(x, y);

// Attack segment with curve factor
var attackTime = 0.3;
var attackLevel = 0.0;  // 0.0 = top
var curveFactor = 0.5;  // 0 = linear, 1 = extreme curve

x = attackTime;
y = attackLevel;

// Interpolate control point between start and end
cy = curveFactor * cy + (1.0 - curveFactor) * y;
cx = (1.0 - curveFactor) * cx + curveFactor * x;

p.quadraticTo(cx, cy, x, y);
// test
/compile

# Verify
/expect p.getLength() > 0.3 is true
/expect isDefined(p.getYAt(0.15)) is true
/exit
// end test
