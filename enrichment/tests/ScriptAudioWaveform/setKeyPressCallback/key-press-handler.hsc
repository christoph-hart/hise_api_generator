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
// Title: Log key presses on a focused panel
const var panel = Content.addPanel("Panel1", 0, 0);
panel.setConsumedKeyPresses("all");
panel.setKeyPressCallback(function(event)
{
    if (!event.isFocusChange)
        Console.print("Key: " + event.description);
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
/expect-logs ["Key: A"]
/exit
// end test
