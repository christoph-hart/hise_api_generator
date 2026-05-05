## setUpdateCallback

**Examples:**


**Pitfalls:**
- The callback fires immediately on registration with the current macro state. If you set up the MacroHandler during `onInit`, the callback body runs synchronously before the next line of init code executes. Place any code that depends on full initialization after the `setUpdateCallback` call.
