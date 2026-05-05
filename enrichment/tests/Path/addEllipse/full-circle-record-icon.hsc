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
// Title: Full circle as a record button icon
// Context: addArc with a full 2*PI sweep is equivalent to addEllipse
// for creating circular paths. Both are used interchangeably in
// practice, but addEllipse is cleaner when a complete circle is needed.

const var recIcon = Content.createPath();
recIcon.addArc([0.0, 0.0, 1.0, 1.0], 0.0, Math.PI * 2.0);

// Equivalent using addEllipse:
const var recIcon2 = Content.createPath();
recIcon2.addEllipse([0.0, 0.0, 1.0, 1.0]);
// test
/compile

# Verify
/expect recIcon.getLength() > 0 is true
/expect recIcon2.getLength() > 0 is true
/expect Math.abs(recIcon.getLength() - recIcon2.getLength()) < 0.1 is true
/exit
// end test
