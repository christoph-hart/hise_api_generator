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
// Title: Tracking a component's visibility state
const var VisPanel1 = Content.addPanel("VisPanel1", 0, 0);
VisPanel1.set("saveInPreset", false);

const var bc = Engine.createBroadcaster({
    "id": "VisWatch",
    "args": ["id", "isVisible"]
});

var visLog = [];

inline function onVisChange(id, isVisible)
{
    visLog.push(id + ":" + isVisible);
}

bc.addListener("handler", "visLogger", onVisChange);
bc.attachToComponentVisibility("VisPanel1", "visSource");
// test
/compile

# Verify
/expect visLog.length is 1
/expect visLog[0] is "VisPanel1:1"
/exit
// end test
