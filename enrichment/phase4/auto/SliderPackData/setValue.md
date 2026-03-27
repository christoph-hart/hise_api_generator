Sets the value of a single slider at the given zero-based index. Use this for programmatic updates where undo support is not needed. For user-initiated edits (click-to-edit, recording, randomisation), prefer `setValueWithUndo()`.

> [!Warning:$WARNING_TO_BE_REPLACED$] Out-of-range indices are silently ignored with no error, which can mask off-by-one bugs.
