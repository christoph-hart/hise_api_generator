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
// Title: Sortable preset table with visible column headers
// Context: A preset browser where users click column headers to sort by
//          name, category, or BPM. The header row needs a visible height
//          for the sort indicator to be meaningful.

const var presetTable = Content.addViewport("PresetTable", 0, 0);
presetTable.set("width", 500);
presetTable.set("height", 350);

presetTable.setTableMode({
    "RowHeight": 33,
    "HeaderHeight": 30,
    "Sortable": true,
    "MultiSelection": false,
    "ScrollOnDrag": true
});
// test
/compile

# Verify
/expect presetTable.getWidth() is 500
/expect presetTable.getHeight() is 350
/exit
// end test
