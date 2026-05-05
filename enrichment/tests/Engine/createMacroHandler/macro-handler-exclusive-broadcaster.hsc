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
Engine.setFrontendMacros(["Macro1", "Macro2", "Macro3", "Macro4"]);

// Context: Plugins with macro/automation systems create the macro
// handler at init, enable exclusive mode (one connection per slot),
// and route updates through a broadcaster for UI synchronization.

const var macroHandler = Engine.createMacroHandler();

// Exclusive mode: each macro slot can only control one parameter.
// Assigning a new connection to an occupied slot replaces the old one.
macroHandler.setExclusiveMode(true);

const var macroBroadcaster = Engine.createBroadcaster({
    "id": "macroBroadcaster",
    "args": ["obj"]
});

// Route macro update events through the broadcaster
macroHandler.setUpdateCallback(macroBroadcaster);

// Initialize with an empty connection list
macroHandler.setMacroDataFromObject([]);

// Listeners react to macro assignment changes
macroBroadcaster.addListener("ui", "update macro display", function(obj)
{
    Console.print("Macro connection changed");
});
// test
/compile

# Verify
/expect typeof macroHandler is "object"
/expect Engine.getMacroName(1) is "Macro1"
/exit
// end test
