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
// Title: Adding child components with bounds array and individual properties
const var dc = Content.addDynamicContainer("DC1", 0, 0);
const var cc = dc.setData({"id": "Root", "type": "Container", "width": 500, "height": 300});

// Using bounds array
var slider = cc.addChildComponent({
    "id": "Vol",
    "type": "Slider",
    "bounds": [10, 10, 128, 48]
});

// Using individual position properties (defaults: 0, 0, 128, 50)
var btn = cc.addChildComponent({
    "id": "Mute",
    "type": "Button",
    "text": "Mute",
    "x": 150, "y": 10, "width": 80, "height": 32
});

Console.print(cc.getNumChildComponents()); // 2
// test
/compile

# Verify
/expect-logs ["2"]
/expect slider.get("type") is "Slider"
/expect btn.get("text") is "Mute"
/exit
// end test
