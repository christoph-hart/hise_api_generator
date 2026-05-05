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
const var ValKnob1 = Content.addKnob("ValKnob1", 0, 0);
ValKnob1.set("saveInPreset", false);

const var bc = Engine.createBroadcaster({
    "id": "ValueWatch",
    "args": ["component", "value"]
});

var lastValue = -1.0;

inline function onValueChange(component, value)
{
    lastValue = value;
}

bc.addListener("handler", "valueLogger", onValueChange);
bc.attachToComponentValue("ValKnob1", "valueSource");
// test
/compile

# Verify
/expect lastValue is 0.0
/exit
// end test
