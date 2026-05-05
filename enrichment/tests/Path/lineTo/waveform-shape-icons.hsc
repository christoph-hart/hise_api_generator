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
// Title: Building waveform shape icons
// Context: Synthesizer UIs commonly display waveform type selectors
// as small path icons. Each waveform shape is built once at init
// from startNewSubPath/lineTo sequences in normalized coordinates.

const var sinePath = Content.createPath();
const var sawPath = Content.createPath();
const var squarePath = Content.createPath();
const var trianglePath = Content.createPath();

// Sine: approximate with short line segments
sinePath.startNewSubPath(0.0, 0.0);
for (i = 0; i < 128; i += 2)
    sinePath.lineTo(i, -127 * Math.sin(2.0 * Math.PI / 126 * i));
sinePath.closeSubPath();

// Sawtooth
sawPath.startNewSubPath(0.0, 0.0);
sawPath.lineTo(0.0, 1.0);
sawPath.lineTo(1.0, -1.0);
sawPath.lineTo(1.0, 0.0);

// Square
squarePath.startNewSubPath(0.0, 0.0);
squarePath.lineTo(0.0, -1.0);
squarePath.lineTo(0.5, -1.0);
squarePath.lineTo(0.5, 1.0);
squarePath.lineTo(1.0, 1.0);
squarePath.lineTo(1.0, 0.0);
squarePath.closeSubPath();

// Triangle
trianglePath.startNewSubPath(0.0, 0.0);
trianglePath.lineTo(0.25, 1.0);
trianglePath.lineTo(0.75, -1.0);
trianglePath.lineTo(1.0, 0.0);
trianglePath.closeSubPath();
// test
/compile

# Verify
/expect sinePath.getLength() > squarePath.getLength() is true
/expect sawPath.getLength() > 0 is true
/expect squarePath.contains([0.25, -0.5]) is true
/expect trianglePath.getLength() > 0 is true
/exit
// end test
