Sets the slider value through the undo manager so the change can be undone by the user. Use this for explicit command-style edits instead of live callback feedback paths.

> **Warning:** Do not call this from `onControl`; it creates recursive undo/control behaviour.
