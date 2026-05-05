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
const var spData = Engine.createAndRegisterSliderPackData(0);
spData.setNumSliders(4);
spData.setAllValues(0.0);

const var sp = Content.addSliderPack("SP1", 0, 0);
sp.set("sliderAmount", 4);
sp.referToData(spData);
sp.setAllValues(0.75);
// test
/compile

# Verify
/expect sp.getNumSliders() is 4
/expect sp.getSliderValueAt(0) is 0.75
/expect sp.getSliderValueAt(3) is 0.75
/exit
// end test
