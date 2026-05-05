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
// Title: Register a value callback for dynamic container children
const var dc = Content.addDynamicContainer("Container1", 0, 0);
dc.setPosition(0, 0, 300, 100);

const var vol = dc.setData({
    "id": "Vol",
    "type": "Slider",
    "x": 10, "y": 10, "width": 128, "height": 48
});

var lastId = "";
var lastValue = -1;

inline function onContainerValue(id, value)
{
    lastId = id;
    lastValue = value;
};

dc.setValueCallback(onContainerValue);
// test
vol.setValue(0.75);
/compile

# Verify
/expect lastId is "Vol"
/expect lastValue is 0.75
/exit
// end test
