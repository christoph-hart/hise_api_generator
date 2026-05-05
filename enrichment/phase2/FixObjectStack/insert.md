## insert

**Examples:**


**Pitfalls:**
- When the stack is near capacity, insert() silently overwrites the last element rather than failing. In production, check `size()` before inserting and manually evict entries to stay within safe bounds.
