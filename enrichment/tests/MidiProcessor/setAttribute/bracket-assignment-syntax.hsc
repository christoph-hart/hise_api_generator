// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add Transposer as "Transposer1"
/exit

/script
/callback onInit
// end setup
// Context: The AssignableObject interface allows mp["ParamName"] = value
// as shorthand for setAttribute. Writing works; reading does not.

const var transposer = Synth.getMidiProcessor("Transposer1");

// Bracket write delegates to setAttribute -- this works
transposer["TransposeAmount"] = 12;

// Equivalent explicit call
transposer.setAttribute(transposer.TransposeAmount, 12);

// WARNING: bracket read always returns 1.0 -- use getAttribute instead
var v = transposer.getAttribute(transposer.TransposeAmount); // correct
// var v = transposer["TransposeAmount"]; // always returns 1.0!
// test
/compile

# Verify
/expect transposer.getAttribute(transposer.TransposeAmount) is 12.0
/exit
// end test
