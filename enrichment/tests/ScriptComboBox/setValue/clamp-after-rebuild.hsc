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
// Title: Clamp selection after rebuilding items
// Context: When a dependent combo box has its items rebuilt, the previous selection
// index may exceed the new item count. Clamp to the new max before calling changed().

const var cbOption = Content.addComboBox("Option", 0, 0);
cbOption.set("items", "A\nB\nC\nD\nE");
cbOption.set("saveInPreset", false);
cbOption.setValue(4); // Select "D"

// Later, the items are rebuilt with fewer entries
cbOption.set("items", "X\nY\nZ");

// Previous value (4) is now out of range -- clamp to new max (3)
cbOption.setValue(Math.min(parseInt(cbOption.getValue()), cbOption.get("max")));
// test
/compile

# Verify
/expect cbOption.getValue() is 3
/expect cbOption.getItemText() is "Z"
/exit
// end test
