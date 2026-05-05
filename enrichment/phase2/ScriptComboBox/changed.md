## changed

**Examples:**


**Pitfalls:**
- When rebuilding a dependent combo box, always call `setValue()` before `changed()`. If the previous selection index exceeds the new item count, the callback would receive an out-of-range value. Reset to 1 (or clamp to the new `max`) first.
