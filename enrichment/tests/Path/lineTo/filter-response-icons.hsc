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
// Context: Simple filter shape icons (HP, BP, LP) use lineTo
// to draw characteristic frequency response silhouettes.

const var hpPath = Content.createPath();
hpPath.startNewSubPath(0.0, 1.0);
hpPath.lineTo(0.25, 0.0);
hpPath.lineTo(1.0, 0.0);

const var bpPath = Content.createPath();
bpPath.startNewSubPath(0.0, 1.0);
bpPath.lineTo(0.2, 0.0);
bpPath.lineTo(0.8, 0.0);
bpPath.lineTo(1.0, 1.0);

const var lpPath = Content.createPath();
lpPath.startNewSubPath(0.0, 0.0);
lpPath.lineTo(0.75, 0.0);
lpPath.lineTo(1.0, 1.0);
// test
/compile

# Verify
/expect bpPath.getLength() > hpPath.getLength() is true
/expect lpPath.getLength() > 0 is true
/expect Math.abs(hpPath.getBounds(1.0)[2] - 1.0) < 0.01 is true
/exit
// end test
