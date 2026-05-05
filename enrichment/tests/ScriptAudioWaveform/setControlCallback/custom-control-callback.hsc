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
// Title: Route a control callback to a per-component handler
const var btn = Content.addButton("Btn1", 0, 0);
btn.set("saveInPreset", false);

var callbackLog = [];

inline function onMyButton(component, value)
{
    callbackLog.push(component.getId() + ": " + value);
};

btn.setControlCallback(onMyButton);
// test
/compile

# Trigger
/ui set Btn1.value 1

# Verify
/expect callbackLog[0] is "Btn1: 1.0"
/exit
// end test
