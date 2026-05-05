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
const var knob = Content.addKnob("Knob1", 0, 0);
const var laf = Content.createLocalLookAndFeel();
knob.setLocalLookAndFeel(laf);

// Add custom classes (component type class is auto-prepended)
knob.setStyleSheetClass(".large .highlighted");
// Result: ".scriptslider .large .highlighted"
// test
/compile

# Verify
/expect knob.getWidth() is 128
/exit
// end test
