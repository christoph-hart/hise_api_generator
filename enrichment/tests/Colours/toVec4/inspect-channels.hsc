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
// Context: toVec4 is useful for debugging or computing with individual
// colour channels as normalized floats.

var rgba = Colours.toVec4(Colours.dodgerblue);

Console.print("R: " + rgba[0]); // R: 0.118 (approx)
Console.print("G: " + rgba[1]); // G: 0.565 (approx)
Console.print("B: " + rgba[2]); // B: 1.0
Console.print("A: " + rgba[3]); // A: 1.0
// test
/compile

# Verify
/expect rgba[2] is 1.0
/expect rgba[3] is 1.0
/expect rgba.length is 4
/exit
// end test
