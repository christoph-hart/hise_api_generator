## setStyleData

**Examples:**


**Pitfalls:**
- When passing a standalone JSON object (not one obtained from `getStyleData()`), every style property that is not included in the object will be reset to its default value. To avoid surprises, always define the complete set of properties in shared configuration objects, or use the get-modify-set pattern for incremental changes.
