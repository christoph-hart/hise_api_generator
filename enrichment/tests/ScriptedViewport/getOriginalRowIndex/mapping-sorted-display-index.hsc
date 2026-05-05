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
// Title: Mapping sorted display index back to data for favorite toggle
// Context: When the table is sorted by a column header, the display row
//          indices no longer match the original data array. Use
//          getOriginalRowIndex() to find the correct position in the
//          original data before mutating it.

const var table = Content.addViewport("DataTable", 0, 0);
table.setTableMode({ "RowHeight": 30, "Sortable": true, "HeaderHeight": 28 });

table.setTableColumns([
    { "ID": "Favorite", "Type": "Button", "MinWidth": 32,
      "Toggle": true,   "Focus": false, "Text": "Fav" },
    { "ID": "Name",     "Label": "Name", "MinWidth": 200 }
]);

var originalData = [
    {"Favorite": 0, "Name": "Item A", "isFavorite": false},
    {"Favorite": 1, "Name": "Item B", "isFavorite": true},
    {"Favorite": 0, "Name": "Item C", "isFavorite": false}
];

table.setTableRowData(originalData);

// Sort by Name descending so display order differs from data order
// After sort: display 0 = Item C (original 2), display 2 = Item A (original 0)
table.setTableSortFunction(function(a, b) { return a.Name > b.Name; });

inline function onTableEvent(event)
{
    if (event.columnID == "Favorite")
    {
        // Map display row to original data index
        local dataIndex = table.getOriginalRowIndex(event.rowIndex);
        originalData[dataIndex].isFavorite = event.value;
        Console.print("Toggled favorite at original index: " + dataIndex);
    }
};

table.setTableCallback(onTableEvent);
// test
/compile

# Verify
/exit
// end test
