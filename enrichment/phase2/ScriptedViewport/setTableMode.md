## setTableMode

**Examples:**


**Pitfalls:**
- When `MultiColumnMode` is enabled, `setValue()` accepts a `[column, row]` array to select a specific cell programmatically. This is essential for highlighting the currently-active item in a sorted table, but the column index refers to the column's position in the `setTableColumns()` array (0-based), not a column ID string.
