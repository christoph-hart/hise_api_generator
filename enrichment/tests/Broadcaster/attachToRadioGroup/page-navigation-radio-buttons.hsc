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
// Title: Page navigation with radio buttons
const var PageBtn1 = Content.addButton("PageBtn1", 0, 0);
PageBtn1.set("radioGroup", 2);
PageBtn1.set("saveInPreset", false);
const var PageBtn2 = Content.addButton("PageBtn2", 130, 0);
PageBtn2.set("radioGroup", 2);
PageBtn2.set("saveInPreset", false);
const var PageBtn3 = Content.addButton("PageBtn3", 260, 0);
PageBtn3.set("radioGroup", 2);
PageBtn3.set("saveInPreset", false);
PageBtn1.setValue(1);

// Context: The most common broadcaster pattern - radio buttons drive page visibility.
// attachToRadioGroup eliminates manual radio group state tracking.

const var pageBc = Engine.createBroadcaster({
    "id": "PageSelector2",
    "args": ["selectedIndex"]
});

var navLog = [];

pageBc.attachToRadioGroup(2, "pageButtons");

const var pageNames = ["Sound", "Effects", "Settings"];

pageBc.addListener("", "switchPage", function(selectedIndex)
{
    navLog.push(pageNames[selectedIndex]);
});
// test
/compile

# Verify
/wait 300ms
/expect navLog.length is 1
/expect navLog[0] is "Sound"
/exit
// end test
