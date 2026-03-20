Sets the selected item through the undo manager, enabling undo/redo for the value change. Pass a 1-based integer index as with `setValue()`.

> **Warning:** Do not call this from control callbacks. It is intended for user-initiated value changes that should be undoable.
