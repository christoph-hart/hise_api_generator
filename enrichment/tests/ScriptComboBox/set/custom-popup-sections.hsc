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
// Title: Custom popup combo box with headers, separators, and submenus
// Context: When useCustomPopup is enabled, the items string supports special
// formatting syntax for organizing complex option lists into sections.

const var cb = Content.addComboBox("FxSelector", 0, 0);
cb.set("useCustomPopup", true);
cb.set("saveInPreset", false);

// Headers (**...**) and separators (___) do not consume selection indices.
// Submenu syntax (Category::Item) creates nested popup menus.
// The value index counts only selectable items.
cb.set("items", [
    "**Filters**",
    "Filters::LowPass",
    "Filters::HighPass",
    "Filters::BandPass",
    "___",
    "**Dynamics**",
    "Dynamics::Compressor",
    "Dynamics::Gate",
    "___",
    "**Spatial**",
    "Spatial::Chorus",
    "Spatial::Delay",
    "Spatial::Reverb"
].join("\n"));

// Value 1 = "LowPass" (first selectable item, not the header)
// Value 4 = "Compressor" (headers and separators are skipped)
cb.setValue(1);
Console.print(cb.getItemText()); // "LowPass" -- submenu prefix stripped
// test
/compile

# Verify
/expect-logs ["LowPass"]
/expect cb.getValue() is 1
/exit
// end test
