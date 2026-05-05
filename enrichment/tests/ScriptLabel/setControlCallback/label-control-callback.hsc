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
const var label = Content.addLabel("StatusLabel", 10, 10);
label.set("saveInPreset", false);

reg lastLabelValue = "";

inline function onMyLabel(component, value)
{
    lastLabelValue = value;
    Console.print(component.getId() + ": " + value); // e.g. StatusLabel: Ready
};

label.setControlCallback(onMyLabel);
// test
/compile

# Trigger
/ui set StatusLabel.value "Ready"

# Verify
/expect lastLabelValue is "Ready"
/exit
// end test
