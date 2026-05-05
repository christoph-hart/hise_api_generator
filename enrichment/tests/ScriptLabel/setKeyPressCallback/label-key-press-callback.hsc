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
panel.setConsumedKeyPresses("all");

reg lastKey = "";

inline function onPanelKeyPress(event)
{
    if (!event.isFocusChange)
    {
        lastKey = event.description;
        Console.print("Key: " + event.description); // Key: A
    }
}

panel.setKeyPressCallback(onPanelKeyPress);
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
/expect lastKey is "A"
/exit
// end test
