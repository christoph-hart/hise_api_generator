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
// Context: When multiple components share a naming convention, use
// getAllComponents to retrieve them all and assign a shared LAF or callback.

Content.makeFrontInterface(900, 600);

const var knob1 = Content.addKnob("GnKnob1", 10, 10);
const var knob2 = Content.addKnob("GnKnob2", 150, 10);
const var knob3 = Content.addKnob("GnKnob3", 290, 10);
const var btn1 = Content.addButton("ToggleBtn", 10, 80);

// Get all components whose name starts with "Gn"
const var gainKnobs = Content.getAllComponents("GnKnob.*");

const var knobLaf = Content.createLocalLookAndFeel();

knobLaf.registerFunction("drawRotarySlider", function(g, obj)
{
    g.setColour(0xFF445566);
    g.fillEllipse([2, 2, obj.area[2] - 4, obj.area[3] - 4]);
});

// Apply LAF to all matching components in one loop
for (k in gainKnobs)
    k.setLocalLookAndFeel(knobLaf);

Console.print(gainKnobs.length); // 3
// test
/compile

# Verify
/expect gainKnobs.length is 3
/exit
// end test
