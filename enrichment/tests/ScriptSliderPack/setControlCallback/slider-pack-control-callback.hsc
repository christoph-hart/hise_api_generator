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
// Title: Custom control callback for slider-pack changes
const var sp = Content.addSliderPack("SP2", 0, 0);
reg lastIndex = -1;

inline function onSliderPackControl(component, value)
{
    lastIndex = value;
}

sp.setControlCallback(onSliderPackControl);
// test
/compile

# Verify
/expect sp.setSliderAtIndex(1, 0.5) || true is true
/expect sp.getSliderValueAt(1) is 0.5
/exit
// end test
