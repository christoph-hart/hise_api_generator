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
// Title: Custom control callback for a combo box
const var cb = Content.addComboBox("CallbackCombo", 0, 0);
cb.set("items", "Sine\nSaw\nSquare");
cb.set("saveInPreset", false);

var callbackLog = [];

inline function onComboChanged(component, value)
{
    callbackLog.push(component.getId() + ": " + parseInt(value));
};

cb.setControlCallback(onComboChanged);
// test
/compile

# Trigger
/ui set CallbackCombo.value 2

# Verify
/expect callbackLog[0] is "CallbackCombo: 2"
/exit
// end test
