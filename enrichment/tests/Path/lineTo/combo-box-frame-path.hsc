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
// Context: A non-rectangular combo box shape defined as a single
// path with an integrated arrow indicator.

const var comboFrame = Content.createPath();
comboFrame.startNewSubPath(0.0, 0.0);
comboFrame.lineTo(1.0, 0.0);
comboFrame.lineTo(1.0, 0.66);
comboFrame.lineTo(0.69, 0.66);
comboFrame.lineTo(0.6, 1.0);
comboFrame.lineTo(0.0, 1.0);
comboFrame.closeSubPath();

// Add a small dropdown triangle as a second sub-path
comboFrame.startNewSubPath(0.8, 0.2);
comboFrame.lineTo(0.9, 0.2);
comboFrame.lineTo(0.85, 0.45);
comboFrame.closeSubPath();
// test
/compile

# Verify
/expect comboFrame.contains([0.5, 0.5]) is true
/expect comboFrame.contains([0.85, 0.3]) is true
/exit
// end test
