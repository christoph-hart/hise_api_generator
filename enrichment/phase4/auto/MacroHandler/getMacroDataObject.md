Returns an array of connection objects representing all active macro-to-parameter mappings across every macro slot. Use this as the starting point for a read-modify-write cycle with `MacroHandler.setMacroDataFromObject()`.

> **Warning:** The returned array is a snapshot, not a live reference. Pushing, removing, or editing entries in the array has no effect on the actual macro connections until you call `setMacroDataFromObject()` with the modified array.
