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
const var spd = Engine.createAndRegisterSliderPackData(0);

// Preallocate for up to 32 sliders
spd.setUsePreallocatedLength(32);

// Set initial values
spd.setNumSliders(8);
spd.setAllValues(0.5);
spd.setValue(0, 1.0);

// Resize preserves existing values (no reallocation)
spd.setNumSliders(16);
Console.print(spd.getValue(0));
// test
/compile

# Verify
/expect spd.getValue(0) is 1.0
/expect spd.getNumSliders() is 16
/exit
// end test
