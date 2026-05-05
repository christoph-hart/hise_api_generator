// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add PolyphonicFilter as "PolyphonicFilter"
/exit

/script
/callback onInit
// end setup
// Context: Every Effect instance exposes its parameters as named constants.
// Use these instead of raw integer indices.
const var filter = Synth.getEffect("PolyphonicFilter");

// Named constants map to parameter indices automatically
filter.setAttribute(filter.Frequency, 1000.0);
filter.setAttribute(filter.Q, 0.7);
filter.setAttribute(filter.Mode, 2); // filter mode enum value
// test
/compile

# Verify
/expect filter.getAttribute(filter.Frequency) is 1000.0
/expect filter.getAttribute(filter.Q) is 0.7
/exit
// end test
