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
// Set a frequency range with perceptual skew
const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("FreqCable");

// 1000 Hz maps to the midpoint (0.5) of the normalised range
cable.setRangeWithSkew(20.0, 20000.0, 1000.0);
cable.setValue(1000.0);

Console.print("Normalized: " + cable.getValueNormalised());
// test
/compile

# Verify
/expect-logs ["Normalized: 0.5"]
/exit
// end test
