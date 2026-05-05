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
reg lastControlValue = -1.0;
reg lastControlId = "";

inline function onSliderControl(component, value)
{
    lastControlId = component.getId();
    lastControlValue = value;
    Console.print(component.getId() + ": " + value);
}

Slider1.setControlCallback(onSliderControl);
// test
/compile

# Trigger
/ui set Slider1.value 0.25

# Verify
/expect lastControlId is "Slider1"
/expect lastControlValue is 0.25
/exit
// end test
