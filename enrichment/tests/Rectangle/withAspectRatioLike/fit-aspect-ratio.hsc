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
// Title: Fitting a 16:9 content area inside a square region
var area = Rectangle(0, 0, 300, 300);
var fitted = area.withAspectRatioLike([0, 0, 16, 9]);
// fitted is centered vertically: [0, 65.625, 300, 168.75]
Console.print("x=" + fitted.x + " y=" + fitted.y);
Console.print("w=" + fitted.width + " h=" + fitted.height);
// test
/compile

# Verify
/expect fitted.width is 300
/expect fitted.height is 168.75
/exit
// end test
