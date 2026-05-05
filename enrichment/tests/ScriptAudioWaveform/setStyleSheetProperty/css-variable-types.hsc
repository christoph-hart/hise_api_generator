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
// Title: Set CSS variables with different unit types
const var knob = Content.addKnob("Knob1", 0, 0);
const var laf = Content.createLocalLookAndFeel();
knob.setLocalLookAndFeel(laf);

// Set a colour variable
knob.setStyleSheetProperty("track-color", 0xFFFF0000, "color");

// Set a size variable
knob.setStyleSheetProperty("track-width", 4, "px");

// Set a percentage variable
knob.setStyleSheetProperty("progress", 0.75, "%");
// test
/compile

# Verify
/expect knob.getWidth() is 128
/exit
// end test
