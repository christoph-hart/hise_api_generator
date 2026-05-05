## clear

**Examples:**


**Pitfalls:**
- In practice, `setEffect("EmptyFX")` achieves the same result as `clear()` and is often preferred in switch/case selection logic because it eliminates a special case for the "off" selection. Both load the EmptyFX placeholder and enable the internal fast-path that skips all processing.
