Sets the value through the undo manager, creating an undoable action. Use this for user-initiated value changes that should support undo/redo.

> **Warning:** Do not call this from `onControl` callbacks. It is intended for external value changes, not callback-driven updates.