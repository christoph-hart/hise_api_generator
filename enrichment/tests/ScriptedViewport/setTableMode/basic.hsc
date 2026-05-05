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
const var Viewport1 = Content.addViewport("Viewport1", 0, 0);
Viewport1.set("width", 400);
Viewport1.set("height", 300);

Viewport1.setTableMode({
    "RowHeight": 28,
    "HeaderHeight": 30,
    "Sortable": true,
    "MultiColumnMode": true,
    "MultiSelection": false
});
// test
/compile

# Verify
/expect Viewport1.getWidth() is 400
/expect Viewport1.getHeight() is 300
/exit
// end test
