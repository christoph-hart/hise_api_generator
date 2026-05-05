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
// Title: Preset handler with post-load callback driving a broadcaster
// Context: Plugins that need to react to preset changes (update UI state,
// reset effects, refresh displays) connect the preset handler's post-load
// callback to a broadcaster that fans out the notification.

const var presetBroadcaster = Engine.createBroadcaster({
    "id": "preset loader",
    "args": ["newPresetFile"]
});

const var presetHandler = Engine.createUserPresetHandler();

// The post-callback fires after a preset finishes loading.
// Passing a broadcaster makes it the notification target.
presetHandler.setPostCallback(presetBroadcaster);

// Listeners react to preset changes independently
presetBroadcaster.addListener("stateTracker", "update current preset", function(newPresetFile)
{
    Console.print("Loaded: " + newPresetFile);
});

presetBroadcaster.addListener("effectReset", "reset effect state", function(newPresetFile)
{
    // Reset parameters that should not carry over between presets
    Console.print("Resetting effects after preset load");
});
// test
/compile

# Verify
/expect typeof presetHandler is "object"
/expect typeof presetBroadcaster is "object"
/exit
// end test
