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
// Title: Multi-column browser table with sorting and selection
// Context: A sortable data browser that supports programmatic cell selection
//          and touch-friendly scrolling. HeaderHeight: 0 hides the column
//          labels when the context makes them unnecessary.

const var browser = Content.addViewport("Browser", 0, 0);
browser.set("width", 600);
browser.set("height", 400);

browser.setTableMode({
    "RowHeight": 30,
    "HeaderHeight": 0,
    "Sortable": true,
    "MultiColumnMode": true,
    "MultiSelection": true,
    "ScrollOnDrag": true
});

browser.setTableColumns([
    {"ID": "Name", "Label": "Name", "MinWidth": 150},
    {"ID": "Value", "Label": "Value", "MinWidth": 100}
]);

var rowData = [];
for (i = 0; i < 5; i++)
    rowData.push({"Name": "Row " + i, "Value": String.fromCharCode(65 + i)});

browser.setTableRowData(rowData);

browser.set("saveInPreset", false);
browser.setValue([0, 2]);
// test
/compile

# Verify
/expect browser.getValue() is [0, 2]
/exit
// end test
