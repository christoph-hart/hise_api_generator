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
const var Viewport1 = Content.addViewport("Viewport1", 0, 0);
Viewport1.setConsumedKeyPresses("all");

reg keyLog = [];

inline function onKeyPress(event)
{
    if (!event.isFocusChange)
        keyLog.push(event.description);
};

Viewport1.setKeyPressCallback(onKeyPress);
// test
Console.testCallback(Viewport1, "setKeyPressCallback", {
    "isFocusChange": false,
    "character": "A",
    "specialKey": false,
    "isWhitespace": false,
    "isLetter": true,
    "isDigit": false,
    "keyCode": 65,
    "description": "A",
    "shift": false,
    "cmd": false,
    "alt": false
});
/compile

# Verify
/expect keyLog.length is 1
/expect keyLog[0] is "A"
/exit
// end test
