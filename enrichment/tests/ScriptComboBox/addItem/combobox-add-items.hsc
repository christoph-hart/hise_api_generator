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
// Title: Dynamically build a combo box item list
const var cb = Content.addComboBox("AddItemCombo", 0, 0);
cb.set("saveInPreset", false);
cb.addItem("First");
cb.addItem("Second");
cb.addItem("Third");
cb.setValue(2);
// test
/compile

# Verify
/expect cb.getValue() is 2
/expect cb.getItemText() is "Second"
/exit
// end test
