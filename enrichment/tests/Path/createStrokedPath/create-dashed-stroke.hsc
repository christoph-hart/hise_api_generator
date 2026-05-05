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
// Title: Creating a dashed stroke path
const var p = Content.createPath();
p.startNewSubPath(0.0, 0.0);
p.lineTo(200.0, 0.0);

var stroked = p.createStrokedPath({
    "Thickness": 3.0,
    "EndCapStyle": "rounded",
    "JointStyle": "curved"
}, [10.0, 5.0]);
// test
/compile

# Verify
/expect stroked.getLength() > p.getLength() is true
/expect stroked.getBounds(1.0)[3] > 0 is true
/exit
// end test
