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

// Consume all keys exclusively
img.setConsumedKeyPresses("all");

// Or consume specific keys
img.setConsumedKeyPresses(["ctrl + S", "F5", "escape"]);
// test
/compile

# Verify
/expect img.getId() is "MyImage"
/exit
// end test
