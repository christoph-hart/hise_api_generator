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
const var panel = Content.addPanel("Panel1", 0, 0);

// Consume all keys exclusively
panel.setConsumedKeyPresses("all");

// Consume specific keys by description string
panel.setConsumedKeyPresses(["ctrl + S", "F5", "escape"]);

// Consume specific keys by JSON object
panel.setConsumedKeyPresses([
    { "keyCode": 65, "ctrl": true },
    { "keyCode": 83, "ctrl": true }
]);

// Verify by registering a callback (would error if keys weren't consumed)
var keyLog = [];
panel.setKeyPressCallback(function(event)
{
    if (!event.isFocusChange)
        keyLog.push(event.keyCode);
});
// test
Console.testCallback(panel, "setKeyPressCallback", {
    "isFocusChange": false,
    "character": "A",
    "specialKey": false,
    "keyCode": 65,
    "description": "A"
});
/compile

# Verify
/expect keyLog[0] is 65
/exit
// end test
