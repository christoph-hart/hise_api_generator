## setUseGlobalUndoManager

**Examples:**


**Pitfalls:**
- Undo is disabled by default. Calling `undo()` or `redo()` without first calling `setUseGlobalUndoManager(true)` throws a script error.
- The undo manager is global (shared via `Engine.undo()`), so undo operations from any MidiPlayer share the same undo stack.
