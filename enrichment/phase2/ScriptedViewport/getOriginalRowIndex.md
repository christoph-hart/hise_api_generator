## getOriginalRowIndex

**Examples:**


**Pitfalls:**
- This method performs an O(n) search internally. For large tables (thousands of rows), avoid calling it in a tight loop. The pattern of walking all display rows and comparing `getOriginalRowIndex(i) == targetIndex` is O(n^2) in the worst case -- cache the mapping if called frequently.
