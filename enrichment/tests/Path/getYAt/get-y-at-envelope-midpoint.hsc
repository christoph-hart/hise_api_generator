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
// Title: Finding control point positions on an envelope curve
// Context: Interactive envelope editors need to know where the curve
// is at specific X positions so they can draw draggable control points.
// After building and scaling the path, getYAt samples the curve at
// the midpoint of each envelope segment to place curve-shape handles.

const var path = Content.createPath();

// Build a simple envelope in normalized space
path.startNewSubPath(0.0, 1.0);
path.quadraticTo(0.1, 0.2, 0.3, 0.0);  // attack
path.lineTo(0.5, 0.4);                   // decay to sustain
path.lineTo(0.7, 0.4);                   // sustain
path.quadraticTo(0.85, 0.7, 1.0, 1.0);  // release

// Scale to pixel space
const var MARGIN = 5;
const var panelWidth = 200;
const var panelHeight = 100;
path.scaleToFit(MARGIN, MARGIN, panelWidth - 2 * MARGIN,
                panelHeight - 2 * MARGIN, false);

// Find Y position at the midpoint of the attack segment
var midX = MARGIN + (panelWidth - 2 * MARGIN) * 0.15;

var y = path.getYAt(midX);

if (isDefined(y))
    Console.print("Y at midX: " + y);
else
    Console.print("No intersection at midX");
// test
/compile

# Verify
/expect isDefined(y) is true
/expect y >= 5.0 && y <= 95.0 is true
/exit
// end test
