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
const var btn1 = Content.addButton("BypassBtn", 10, 10);
const var btn2 = Content.addButton("BypassBtn", 10, 10);
Console.assertTrue(btn1 == btn2);
// test
/compile

# Verify
/expect btn1 == btn2 is true
/exit
// end test
