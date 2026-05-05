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
// Context: Assigning distinct colours to items in a list (channels,
// categories, notes) by distributing hue values evenly around the
// colour wheel. Start from any base colour -- only its saturation
// and brightness are preserved; the hue is replaced.

const var NUM_ITEMS = 8;

// Generate a palette of 8 evenly-spaced hues
for (i = 0; i < NUM_ITEMS; i++)
{
    var c = Colours.withHue(Colours.red, i / NUM_ITEMS);
    c = Colours.withSaturation(c, 0.5);
    c = Colours.withBrightness(c, 0.4);
    Console.print("Item " + i + ": " + c);
}
// test
/compile

# Verify
/expect Colours.toVec4(Colours.withHue(Colours.red, 0.0))[0] == Colours.toVec4(Colours.red)[0] is true
/expect Colours.toVec4(Colours.withHue(Colours.red, 0.5))[0] != Colours.toVec4(Colours.red)[0] is true
/expect Colours.toVec4(Colours.withHue(Colours.red, 0.333))[1] > 0.4 is true
/exit
// end test
