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
spd.setAllValues(0.5);

reg lastChangedIndex = -99;

inline function onContentChanged(index)
{
    lastChangedIndex = index;
};

spd.setContentCallback(onContentChanged);
// test
spd.setValue(2, 0.8);
/compile

# Verify
/expect lastChangedIndex is 2
/exit
// end test
