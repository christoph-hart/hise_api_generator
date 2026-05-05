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
// Context: Base64 encoding is more compact than byte arrays for
// storing complex path data. Many plugins maintain icon libraries
// as namespace objects with base64-encoded paths.

// Create a path, serialize it to base64, then reload from that string
const var original = Content.createPath();
original.addRectangle([0, 0, 50, 50]);
var b64 = original.toBase64();

const var reloaded = Content.createPath();
reloaded.loadFromData(b64);
// test
/compile

# Verify
/expect reloaded.getLength() > 0 is true
/expect original.toBase64() == reloaded.toBase64() is true
/exit
// end test
