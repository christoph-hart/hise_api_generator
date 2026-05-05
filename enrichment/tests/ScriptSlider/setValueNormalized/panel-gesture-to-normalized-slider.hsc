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
// Title: Drive a hidden parameter slider from custom panel gestures
// Context: A custom panel calculates pointer position, then forwards normalized values into a ScriptSlider.

const var hiddenThreshold = Content.addKnob("HiddenThreshold", 0, 0);
hiddenThreshold.set("visible", false);
hiddenThreshold.set("min", -48.0);
hiddenThreshold.set("max", 0.0);
reg lastThresholdValue = 0.0;

const var gesturePanel = Content.addPanel("ThresholdSurface", 0, 0);
gesturePanel.set("width", 160);
gesturePanel.set("height", 120);
gesturePanel.set("min", 0.0);
gesturePanel.set("max", 1.0);

inline function onSurfaceControl(component, value)
{
    local normalized = 1.0 - value;
    hiddenThreshold.setValueNormalized(normalized);
    lastThresholdValue = hiddenThreshold.getValue();
    hiddenThreshold.changed();
}

gesturePanel.setControlCallback(onSurfaceControl);
// test
inline function triggerThresholdSurface(value)
{
    onSurfaceControl(gesturePanel, value);
    return lastThresholdValue;
}
/compile

# Verify
/expect triggerThresholdSurface(0.25) is -12.0
/expect lastThresholdValue is -12.0
/expect hiddenThreshold.getValue() is -12.0
/exit
// end test
