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
const var bc = Engine.createBroadcaster({
    "id": "SizeWatch",
    "args": ["width", "height"]
});

var currentWidth = 0;
var currentHeight = 0;

inline function onSizeChange(width, height)
{
    currentWidth = width;
    currentHeight = height;
}

bc.addListener("handler", "sizeLogger", onSizeChange);
bc.attachToInterfaceSize("sizeSource");
// test
/compile

# Verify
/expect currentWidth > 0 is true
/expect currentHeight > 0 is true
/exit
// end test
