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
// Title: Selecting an item by original data index in a sorted table
// Context: After sorting, display indices no longer match data indices.
//          Walk the display rows with getOriginalRowIndex() to find which
//          one corresponds to a known data index, then select it.

const var sortedTable = Content.addViewport("SortedTable", 0, 0);
sortedTable.setTableMode({"RowHeight": 30, "Sortable": true, "HeaderHeight": 28});
sortedTable.setTableColumns([{"ID": "Name", "Label": "Name", "MinWidth": 200}]);

var fruits = [
    {"Name": "Cherry"},
    {"Name": "Apple"},
    {"Name": "Banana"}
];

sortedTable.setTableRowData(fruits);

// Sort alphabetically: display 0 = Apple (orig 1), 1 = Banana (orig 2), 2 = Cherry (orig 0)
sortedTable.setTableSortFunction(function(a, b) { return a.Name < b.Name; });

inline function selectByDataIndex(dataIndex)
{
    for (i = 0; i < fruits.length; i++)
    {
        if (sortedTable.getOriginalRowIndex(i) == dataIndex)
        {
            sortedTable.set("saveInPreset", false);
            sortedTable.setValue(i);
            return i;
        }
    }
    return -1;
}

// Select "Cherry" which is original index 0, now at display index 2
var displayIndex = selectByDataIndex(0);
// test
/compile

# Verify
/exit
// end test
