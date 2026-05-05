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
// Context: getItemText() returns an empty string when the value is 0 (nothing
// selected) and "No options" when the value exceeds the item count.
// Guard against both in cascading selector patterns where items may be rebuilt.

const var cbGuard = Content.addComboBox("GuardCombo", 0, 0);
cbGuard.set("items", "Ambience\nChambers\nHalls");
cbGuard.set("saveInPreset", false);

// Explicitly reset to 0 (nothing selected) -- getItemText() returns ""
cbGuard.setValue(0);
Console.print(cbGuard.getItemText()); // ""

cbGuard.setValue(2);
Console.print(cbGuard.getItemText()); // "Chambers"
// test
/compile

# Verify
/expect-logs ["", "Chambers"]
/exit
// end test
