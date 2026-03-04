## getOriginalRowIndex

**Examples:**

```javascript:mapping-sorted-display-index
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
```
```json:testMetadata:mapping-sorted-display-index
{
  "testable": true,
  "verifyScript": {
    "type": "REPL",
    "expression": "originalData.length",
    "value": 3
  }
}
```


```javascript:selecting-the-current-item
// Title: Selecting the current item in a sorted table after a load event
// Context: After loading a preset, walk the display rows and compare
//          getOriginalRowIndex() to find which display row corresponds
//          to the known original-data index, then select it.

inline function selectItemByDataIndex(dataIndex)
{
    for (i = 0; i < currentRows.length; i++)
    {
        if (table.getOriginalRowIndex(i) == dataIndex)
        {
            table.setValue(i);
            return;
        }
    }

    // No match found -- deselect
    table.setValue(-1);
};

```
```json:testMetadata:selecting-the-current-item
{
  "testable": false
}
```

**Pitfalls:**
- This method performs an O(n) search internally. For large tables (thousands of rows), avoid calling it in a tight loop. The pattern of walking all display rows and comparing `getOriginalRowIndex(i) == targetIndex` is O(n^2) in the worst case -- cache the mapping if called frequently.
