## setTableMode

**Examples:**

```javascript
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
```

```javascript
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
```

**Pitfalls:**
- When `MultiColumnMode` is enabled, `setValue()` accepts a `[column, row]` array to select a specific cell programmatically. This is essential for highlighting the currently-active item in a sorted table, but the column index refers to the column's position in the `setTableColumns()` array (0-based), not a column ID string.
