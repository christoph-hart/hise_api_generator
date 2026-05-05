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
const var MeterPanel = Content.addPanel("MeterPanel", 0, 0);

// Context: A DSP network writes its output level to a global cable.
// The script registers an async callback to trigger a panel repaint
// whenever the value changes, keeping the visual in sync.

const var rm = Engine.getGlobalRoutingManager();
const var levelCable = rm.getCable("OutputLevel");

reg currentLevel = 0.0;

inline function onLevelChanged(value)
{
    currentLevel = value;
    MeterPanel.repaint();
};

levelCable.registerCallback(onLevelChanged, AsyncNotification);
// test
levelCable.setValue(0.75);
/compile

# Verify
/wait 300ms
/expect currentLevel is 0.75
/exit
// end test
