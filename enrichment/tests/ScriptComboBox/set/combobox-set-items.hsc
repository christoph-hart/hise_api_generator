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
const var cb = Content.addComboBox("SetItemsCombo", 0, 0);
cb.set("items", "Option A\nOption B\nOption C");
cb.set("text", "Choose...");
cb.set("fontName", "Default");
cb.set("fontSize", 14);
// test
/compile

# Verify
/expect cb.get("items") is "Option A\nOption B\nOption C"
/expect cb.get("text") is "Choose..."
/exit
// end test
