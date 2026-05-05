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
Content.makeFrontInterface(800, 500);

const var size = Content.getInterfaceSize();
Console.print(size[0]);
Console.print(size[1]);
// test
/compile

# Verify
/expect size[0] is 800
/expect size[1] is 500
/exit
// end test
