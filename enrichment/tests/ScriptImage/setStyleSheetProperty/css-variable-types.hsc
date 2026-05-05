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

// Set a size variable
img.setStyleSheetProperty("border-width", 2, "px");

// Set a percentage variable
img.setStyleSheetProperty("opacity", 0.8, "%");
// test
/compile

# Verify
/expect img.getId() is "MyImage"
/exit
// end test
