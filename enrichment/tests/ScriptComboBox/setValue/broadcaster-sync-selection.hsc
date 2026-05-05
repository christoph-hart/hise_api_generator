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
// Context: A Broadcaster drives the combo box value from an external source
// (e.g., a zoom level changed elsewhere). The combo box reflects the current
// state without triggering its own callback.

const var ZOOM_LEVELS = [0.75, 1.0, 1.25, 1.5, 2.0];

const var cbZoom = Content.addComboBox("ZoomSelector", 0, 0);
cbZoom.set("items", "75%\n100%\n125%\n150%\n200%");
cbZoom.set("saveInPreset", false);

const var zoomBroadcaster = Engine.createBroadcaster({
    "id": "zoomSync",
    "args": ["value"]
});

// When the broadcaster fires, update the combo box to match
zoomBroadcaster.addListener(cbZoom, "update zoom selector", function(value)
{
    // Find which index matches the zoom value and select it
    local idx = ZOOM_LEVELS.indexOf(value) + 1;
    this.setValue(idx);
});
// test
zoomBroadcaster.sendSyncMessage([1.25]);
/compile

# Verify
/expect cbZoom.getValue() is 3
/expect cbZoom.getItemText() is "125%"
/exit
// end test
