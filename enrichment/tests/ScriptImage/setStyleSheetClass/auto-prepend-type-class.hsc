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

// Add custom classes (component type class is auto-prepended)
img.setStyleSheetClass(".thumbnail .highlighted");
// Result: ".scriptimage .thumbnail .highlighted"
// test
/compile

# Verify
/expect img.getId() is "MyImage"
/exit
// end test
