## substring

**Examples:**


**Pitfalls:**
- Always pass two arguments. Unlike JavaScript, omitting the end index is unreliable. Use a large number like 10000 to mean "rest of string" - HISE clamps it to the actual string length.
