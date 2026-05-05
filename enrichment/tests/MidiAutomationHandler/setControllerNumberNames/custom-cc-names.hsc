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
// Title: Customize CC popup with named controllers
const var mah = Engine.createMidiAutomationHandler();

// Only show CC1 and CC11 in the popup
mah.setControllerNumbersInPopup([1, 11]);

// Set the section header and give them readable names
// Note: nameArray is indexed by CC number, so we need
// entries at index 1 and 11
var names = [];
names[1] = "Mod Wheel";
names[11] = "Expression";
mah.setControllerNumberNames("Performance", names);
// test
/compile

# Verify
/expect names.length is 12
/expect isDefined(names[1]) && isDefined(names[11]) is true
/expect isDefined(names[0]) is false
/exit
// end test
