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
// Title: Registering a custom control callback
const var btn = Content.addButton("CbBtn", 0, 0);
btn.set("saveInPreset", false);

var callbackLog = [];

inline function onButtonToggled(component, value)
{
    callbackLog.push(component.getId() + ":" + value);
};

btn.setControlCallback(onButtonToggled);
// test
btn.setValue(1);
btn.changed();
/compile

# Trigger
/ui set CbBtn.value 1

# Verify
/expect callbackLog[0] is "CbBtn:1.0"
/exit
// end test
