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
// Title: Query usable desktop dimensions
var desktop = Settings.getUserDesktopSize();
var maxWidth = desktop[0];
var maxHeight = desktop[1];
Console.print("Desktop: " + maxWidth + " x " + maxHeight);
// test
/compile

# Verify
/expect desktop.length is 2
/expect desktop[0] > 0 is true
/expect desktop[1] > 0 is true
/exit
// end test
