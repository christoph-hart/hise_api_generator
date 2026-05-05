## setTimeSignature

**Examples:**


**Pitfalls:**
- The `Tempo` property in the time signature object is read-only. Setting it has no effect - tempo is derived from the host/master clock, not the sequence metadata.
