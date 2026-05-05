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
// Context: A larger interface uses many ScriptSlider controls and keeps gesture mappings consistent.

const var sliderIds = ["GainA", "GainB", "GainC", "GainD"];
const var sliders = [];

for (id in sliderIds)
    sliders.push(Content.addKnob(id, 0, 0));

// Create constants once from one slider and reuse them.
const var mods = sliders[0].createModifiers();

for (s in sliders)
{
    s.setModifiers(mods.TextInput, mods.shiftDown);
    s.setModifiers(mods.FineTune, mods.ctrlDown | mods.cmdDown);
    s.setModifiers(mods.ResetToDefault, [mods.doubleClick, mods.noKeyModifier]);
}
// test
/compile

# Verify
/expect mods.TextInput is "TextInput"
/expect mods.ResetToDefault is "ResetToDefault"
/expect mods.doubleClick > 0 is true
/exit
// end test
