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
// Title: Watching a component's text property for changes
const var PropKnob1 = Content.addKnob("PropKnob1", 0, 0);
PropKnob1.set("saveInPreset", false);

const var bc = Engine.createBroadcaster({
    "id": "PropWatcher",
    "args": ["component", "property", "value"]
});

var lastProp = "";
var lastVal = "";

inline function onPropChange(component, property, value)
{
    lastProp = property;
    lastVal = value;
}

bc.addListener("handler", "propLogger", onPropChange);
bc.attachToComponentProperties("PropKnob1", "text", "propSource");
Content.getComponent("PropKnob1").set("text", "Hello");
// test
/compile

# Verify
/wait 300ms
/expect lastProp is "text"
/expect lastVal is "Hello"
/exit
// end test
