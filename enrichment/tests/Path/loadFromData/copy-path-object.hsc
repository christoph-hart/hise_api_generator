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
// Context: loadFromData also accepts a Path object directly,
// which copies the geometry from the source path.

const var source = Content.createPath();
source.startNewSubPath(0.0, 0.0);
source.lineTo(1.0, 0.5);
source.lineTo(0.0, 1.0);
source.closeSubPath();

const var copy = Content.createPath();
copy.loadFromData(source);
// test
/compile

# Verify
/expect copy.getLength() > 0 is true
/expect source.toBase64() == copy.toBase64() is true
/exit
// end test
