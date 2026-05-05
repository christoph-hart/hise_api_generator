## setMacroDataFromObject

**Examples:**


**Pitfalls:**
- This method is destructive: it clears ALL existing macro connections before applying the new array. Passing a partial list removes connections not in the array. Use the read-modify-write pattern (`getMacroDataObject()` -> modify -> `setMacroDataFromObject()`) to change individual connections without losing others.
