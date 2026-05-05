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
spd.setNumSliders(8);
spd.setAllValues(0.5);

// Get the buffer reference and modify directly
var buf = spd.getDataAsBuffer();
buf[0] = 1.0;

// The slider pack data is now modified
Console.print(spd.getValue(0));
// test
/compile

# Verify
/expect spd.getValue(0) is 1.0
/expect spd.getValue(1) is 0.5
/exit
// end test
