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
// Title: Handling key presses on a button
const var btn = Content.addButton("KeyPressBtn", 0, 0);
btn.setConsumedKeyPresses("all");

var lastKey = "";

inline function onKeyPress(event)
{
    if (!event.isFocusChange)
        lastKey = event.description;
};

btn.setKeyPressCallback(onKeyPress);
// test
Console.testCallback(btn, "setKeyPressCallback", {
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
