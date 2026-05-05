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
const var dc = Content.addDynamicContainer("DC3", 0, 0);
const var cc = dc.setData({"id": "Knob1", "type": "Slider", "defaultValue": 0.0});

reg lastVal = -1.0;

inline function onKnobValue(value)
{
    lastVal = value;
}

cc.setControlCallback(onKnobValue);
cc.setValue(0.75);
cc.changed();
// test
/compile

# Verify
/expect lastVal is 0.75
/exit
// end test
