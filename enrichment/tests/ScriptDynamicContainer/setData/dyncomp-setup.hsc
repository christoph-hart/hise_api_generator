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
// Title: Create dynamic controls from JSON data
const var dc = Content.addDynamicContainer("FXControls", 0, 0);
dc.setPosition(0, 0, 400, 200);

const var root = dc.setData([
{
    "id": "GainKnob",
    "type": "Slider",
    "text": "Gain",
    "min": -100.0,
    "max": 0.0,
    "mode": "Decibel",
    "x": 10, "y": 10, "width": 128, "height": 48
},
{
    "id": "BypassBtn",
    "type": "Button",
    "text": "Bypass",
    "x": 150, "y": 10, "width": 100, "height": 32
}]);

Console.print(dc.getWidth());
// test
/compile

# Verify
/expect-logs ["400"]
/expect dc.getWidth() is 400
/exit
// end test
