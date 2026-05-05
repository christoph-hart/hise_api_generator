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
// Title: Linking two SliderPackData objects to share data
const var spd1 = Engine.createAndRegisterSliderPackData(0);
const var spd2 = Engine.createAndRegisterSliderPackData(1);

spd1.setNumSliders(4);
spd1.setAllValues(0.5);

// Link spd2 to spd1 -- they now share data
spd2.linkTo(spd1);

// Changes through spd1 are visible through spd2
spd1.setValue(0, 1.0);
Console.print(spd2.getValue(0));
// test
/compile

# Verify
/expect spd2.getValue(0) is 1.0
/expect spd2.getNumSliders() is 4
/exit
// end test
