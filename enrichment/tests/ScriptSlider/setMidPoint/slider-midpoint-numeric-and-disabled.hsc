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
const var Slider1 = Content.addKnob("Slider1", 0, 0);

Slider1.setRange(-48.0, 0.0, 0.1);
Slider1.setMidPoint(-12.0);      // Numeric midpoint route
Slider1.setMidPoint("disabled"); // Explicit no-skew route

Slider1.setRange(0.0, 10.0, 0.1);
Slider1.setMidPoint("1.5");     // Numeric string route
// test
/compile

# Verify
/exit
// end test
