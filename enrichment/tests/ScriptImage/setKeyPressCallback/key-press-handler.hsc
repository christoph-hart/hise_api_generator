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
const var img = Content.addImage("MyImage", 0, 0);
img.setConsumedKeyPresses("all");

inline function onKeyPress(event)
{
    if (!event.isFocusChange)
        Console.print("Key: " + event.description);
};

img.setKeyPressCallback(onKeyPress);
// test
Console.testCallback(img, "setKeyPressCallback", {
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
