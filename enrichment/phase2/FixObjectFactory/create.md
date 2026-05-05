## create

**Examples:**


**Pitfalls:**
- The temp object pattern requires overwriting ALL properties before each `insert()`. If you forget to reset a property, the previous event's value leaks into the new entry. Initialize every field explicitly, not just the ones that changed.
