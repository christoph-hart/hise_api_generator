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
// Title: Configure a curated CC popup with readable names
// Context: An instrument exposes a fixed set of CC-controllable parameters.
// The popup should only show relevant CC numbers with descriptive labels
// instead of the default full list of 128 CCs.

const var mah = Engine.createMidiAutomationHandler();

// Define the CC numbers available for automation
const var NUM_SLOTS = 4;
const var CC_START = 20;
const var ccNumbers = [];
const var names = [];

for (i = 0; i < NUM_SLOTS; i++)
{
    ccNumbers.push(CC_START + i);
    names.push("Slot " + (i + 1));
}

// One CC per parameter - grays out already-assigned CCs in the popup
mah.setExclusiveMode(true);

// Only these CC numbers appear in the right-click automation popup
mah.setControllerNumbersInPopup(ccNumbers);

// Set the popup section header and per-CC display names.
// The nameArray is indexed by CC number, so populate the correct indices.
var nameArray = [];
for (i = 0; i < NUM_SLOTS; i++)
    nameArray[CC_START + i] = names[i];

mah.setControllerNumberNames("Automation", nameArray);
// test
/compile

# Verify
/expect ccNumbers.length is 4
/expect ccNumbers[3] is 23
/expect nameArray[21] is "Slot 2"
/expect !isDefined(nameArray[0]) is true
/exit
// end test
