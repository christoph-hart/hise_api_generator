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
// Title: Updating a lock icon based on a toggle button's state
const var LockToggle = Content.addButton("LockToggle", 0, 0);
LockToggle.set("saveInPreset", false);
const var LockIcon = Content.addLabel("LockIcon", 150, 0);
LockIcon.set("saveInPreset", false);

// Context: A button toggles between locked/unlocked states. A broadcaster
// watches the button value and updates an icon component's text property
// (used for icon path selection) via addComponentPropertyListener.

const var lockBc = Engine.createBroadcaster({
    "id": "LockIconUpdater",
    "args": ["component", "value"]
});

lockBc.attachToComponentValue("LockToggle", "lockState");

lockBc.addComponentPropertyListener("LockIcon", "text",
    "updateIcon",
    function(targetIndex, component, value)
{
    return value ? "lock_closed" : "lock_open";
});
// test
/compile

# Verify
/expect Content.getComponent("LockIcon").get("text") is "lock_open"
/exit
// end test
