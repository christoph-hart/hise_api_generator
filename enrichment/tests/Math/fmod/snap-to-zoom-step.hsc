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
// Context: Zoom handlers and grid-based controls need to quantize
// a continuous drag value to fixed increments. Subtracting the
// remainder from fmod rounds down to the nearest step.

const var ZOOM_STEP = 0.25;
const var MIN_ZOOM = 0.5;
const var MAX_ZOOM = 2.0;

// In a drag callback:
var rawZoom = 1.37;  // Continuous value from drag gesture

// Snap to nearest step below
rawZoom -= Math.fmod(rawZoom, ZOOM_STEP);
// Clamp to valid range
rawZoom = Math.range(rawZoom, MIN_ZOOM, MAX_ZOOM);

Console.print(rawZoom); // 1.25
// test
/compile

# Verify
/expect rawZoom is 1.25
/exit
// end test
