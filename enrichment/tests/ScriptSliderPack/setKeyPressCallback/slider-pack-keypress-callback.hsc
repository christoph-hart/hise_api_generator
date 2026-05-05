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
// Title: Handle consumed key presses on a slider-pack
const var sp = Content.addSliderPack("SPKey", 0, 0);
sp.setConsumedKeyPresses("all");
reg lastKeyCode = -1;

inline function onKeyPress(event)
{
    if (!event.isFocusChange)
        lastKeyCode = event.keyCode;
}

sp.setKeyPressCallback(onKeyPress);
// test
Console.testCallback(sp, "setKeyPressCallback", {
    "isFocusChange": false,
    "character": "A",
    "specialKey": false,
    "keyCode": 65,
    "description": "A",
    "shift": false,
    "cmd": false,
    "alt": false
});
/compile

# Verify
/expect lastKeyCode is 65
/exit
// end test
