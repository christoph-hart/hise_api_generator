Sets the value through the undo manager, allowing the change to be reverted. Use this for user-initiated value changes that should support undo/redo.

> [!Warning:$WARNING_TO_BE_REPLACED$] Do not call this from `onControl` or a custom control callback. The undo operation itself triggers the control callback, creating a feedback loop.
