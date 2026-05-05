## getMagnitude

**Examples:**


**Pitfalls:**
- Calling `getMagnitude()` once over the full buffer is not enough when you need the end position of audible content; scan in windows.
