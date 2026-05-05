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
// Title: Multi-purpose callback dispatching by component ID
// Context: A single callback handles multiple combo boxes created in a loop.
// The component's ID encodes its role, enabling one function to drive different behaviors.

var dispatchLog = [];

inline function onComboChanged(component, value)
{
    local id = component.getId();
    local idx = parseInt(value) - 1;

    if (id.contains("FilterType"))
        dispatchLog.push("filter:" + idx);
    else if (id.contains("Waveform"))
        dispatchLog.push("waveform:" + idx);
}

// Create combo boxes in a loop, all sharing the same callback
for (i = 1; i <= 2; i++)
{
    local cb = Content.addComboBox("FilterType" + i, (i - 1) * 200, 0);
    cb.set("items", "LP\nHP\nBP");
    cb.set("saveInPreset", false);
    cb.setControlCallback(onComboChanged);
}
// test
/compile

# Trigger
/ui set FilterType1.value 2

# Verify
/expect dispatchLog[0] is "filter:1"
/exit
// end test
