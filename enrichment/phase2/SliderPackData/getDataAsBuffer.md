## getDataAsBuffer

**Examples:**


**Pitfalls:**
- When using `getDataAsBuffer()` for read-only iteration (e.g., copying values into an array), prefer `for...in` over index-based loops for better performance. The buffer reference is live, so do not modify it during iteration if you are also reading from it in the same loop.
