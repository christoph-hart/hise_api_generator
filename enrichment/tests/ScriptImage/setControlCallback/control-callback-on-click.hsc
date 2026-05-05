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
img.set("allowCallbacks", "Clicks Only");
img.set("saveInPreset", false);

inline function onImageClicked(component, value)
{
    Console.print(component.getId() + ": " + value);
};

img.setControlCallback(onImageClicked);
// test
/compile

# Trigger
/ui set MyImage.value 1

# Verify
/expect img.getValue() is 1
/exit
// end test
