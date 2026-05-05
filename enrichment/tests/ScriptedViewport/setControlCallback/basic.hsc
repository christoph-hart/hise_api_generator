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
const var Viewport1 = Content.addViewport("Viewport1", 0, 0);
Viewport1.set("useList", true);
Viewport1.set("items", "Item A\nItem B\nItem C");
Viewport1.set("saveInPreset", false);

reg controlLog = [];

inline function onViewportChanged(component, value)
{
    controlLog.push(value);
};

Viewport1.setControlCallback(onViewportChanged);
// test
/compile

# Trigger
/ui set Viewport1.value 1

# Verify
/expect controlLog[0] is 1
/exit
// end test
