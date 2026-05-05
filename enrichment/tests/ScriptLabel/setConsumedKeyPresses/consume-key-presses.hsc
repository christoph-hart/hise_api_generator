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
const var panel = Content.addPanel("KeyPanel", 0, 0);

// Consume all keys exclusively
panel.setConsumedKeyPresses("all");

// Consume specific keys by description string
panel.setConsumedKeyPresses(["ctrl + S", "F5", "escape"]);

// Consume specific keys by JSON object
panel.setConsumedKeyPresses([
    { "keyCode": 65, "ctrl": true },
    { "keyCode": 83, "ctrl": true }
]);
// test
reg lastKey = "";

inline function onPanelKeyPress(event)
{
    if (!event.isFocusChange)
        lastKey = event.description;
}

panel.setKeyPressCallback(onPanelKeyPress);

Console.testCallback(panel, "setKeyPressCallback", {
    "isFocusChange": false,
    "character": "A",
    "specialKey": false,
    "keyCode": 65,
    "description": "A"
});
/compile

# Verify
/expect lastKey is "A"
/exit
// end test
