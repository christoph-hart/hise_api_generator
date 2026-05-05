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
// Title: Monitor automation changes with an update callback
const var mah = Engine.createMidiAutomationHandler();

var lastData = [];

inline function onAutomationChanged(data)
{
    lastData = data;
    Console.print("Automation changed: " + data.length + " entries");
};

// Registers and fires immediately with current state
mah.setUpdateCallback(onAutomationChanged);
// test
/compile

# Verify
/expect-logs ["Automation changed: 0 entries"]
/exit
// end test
