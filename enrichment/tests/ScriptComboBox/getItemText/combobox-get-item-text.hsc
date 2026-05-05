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
const var cb = Content.addComboBox("ItemTextCombo", 0, 0);
cb.set("items", "Sine\nSaw\nSquare");
cb.set("saveInPreset", false);
cb.setValue(1);

Console.print(cb.getItemText());
// test
/compile

# Verify
/expect-logs ["Sine"]
/exit
// end test
