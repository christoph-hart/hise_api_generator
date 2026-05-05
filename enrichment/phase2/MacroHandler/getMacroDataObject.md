## getMacroDataObject

**Examples:**


**Pitfalls:**
- The returned array is not a reference to the internal state. After calling `remove()` or `push()` on the snapshot, you must call `setMacroDataFromObject()` to apply the changes - modifications to the array alone have no effect.
