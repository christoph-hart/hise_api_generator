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
// Title: HSL roundtrip with alpha correction
var hsl = Colours.toHsl(Colours.dodgerblue);
hsl[0] += 0.1;
hsl[3] = Math.round(hsl[3] * 255);
var shifted = Colours.fromHsl(hsl);
// test
/compile

# Verify
/expect shifted != Colours.dodgerblue is true
/expect Colours.toVec4(shifted)[3] is 1.0
/exit
// end test
