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
spd.setNumSliders(4);

// Set all sliders to 0.5
spd.setAllValues(0.5);

// Set from an array
spd.setAllValues([0.1, 0.2, 0.3, 0.4]);
Console.print(spd.getValue(2));
// test
/compile

# Verify
/expect spd.getValue(0) is 0.1
/expect spd.getValue(2) is 0.3
/exit
// end test
