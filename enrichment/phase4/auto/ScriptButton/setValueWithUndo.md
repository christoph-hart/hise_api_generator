Sets the button's value through the undo manager, allowing the change to be reverted with undo. Pass 0 for off or 1 for on. Use this for user-initiated actions where undo support is expected.

> **Warning:** Do not call this from `onControl` or a custom control callback. The undo operation itself triggers the control callback, creating a feedback loop.