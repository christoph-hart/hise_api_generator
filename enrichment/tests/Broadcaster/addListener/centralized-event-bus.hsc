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
// Title: Centralized event bus - one broadcaster notifies multiple independent modules
const var Page1 = Content.addPanel("Page1", 0, 50);
Page1.set("saveInPreset", false);
const var Page2 = Content.addPanel("Page2", 0, 150);
Page2.set("saveInPreset", false);
const var Page3 = Content.addPanel("Page3", 0, 250);
Page3.set("saveInPreset", false);
const var HeaderLabel = Content.addLabel("HeaderLabel", 0, 0);
HeaderLabel.set("saveInPreset", false);
const var PB1 = Content.addButton("PB1", 0, 350);
PB1.set("radioGroup", 9);
PB1.set("saveInPreset", false);
const var PB2 = Content.addButton("PB2", 130, 350);
PB2.set("radioGroup", 9);
PB2.set("saveInPreset", false);
const var PB3 = Content.addButton("PB3", 260, 350);
PB3.set("radioGroup", 9);
PB3.set("saveInPreset", false);
PB1.setValue(1);

// Context: In large plugins, a single broadcaster with listeners in many separate scripts
// decouples feature modules. This pattern replaces direct function calls between scripts.

const var pageBroadcaster = Engine.createBroadcaster({
    "id": "PageSelector",
    "args": ["index"]
});

pageBroadcaster.attachToRadioGroup(9, "pageButtons");

// Listener 1: Toggle page visibility
const var pages = [Content.getComponent("Page1"),
                   Content.getComponent("Page2"),
                   Content.getComponent("Page3")];

pageBroadcaster.addListener(pages, "showPage", function(index)
{
    for (i = 0; i < this.length; i++)
        this[i].set("visible", i == index);
});

// Listener 2: Update header label (independent module, same broadcaster)
const var headerLabel = Content.getComponent("HeaderLabel");

pageBroadcaster.addListener(headerLabel, "updateHeader", function(index)
{
    local names = ["Sound", "Effects", "Settings"];
    this.set("text", names[index]);
});
// test
/compile

# Verify
/wait 300ms
/expect Content.getComponent("Page1").get("visible") is true
/expect Content.getComponent("Page2").get("visible") is false
/expect Content.getComponent("Page3").get("visible") is false
/expect Content.getComponent("HeaderLabel").get("text") is "Sound"
/exit
// end test
