## copy

**Examples:**


**Pitfalls:**
- When extracting multiple properties in sequence, allocate all target Buffers at init time with the same size as the array. Creating Buffers inside a timer callback defeats the allocation-free design of FixObjectArray.
