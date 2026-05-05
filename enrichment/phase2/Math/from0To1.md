## from0To1

**Examples:**


**Pitfalls:**
- When parameter metadata uses the scriptnode convention (`MinValue`/`MaxValue`/`SkewFactor`), the skew factor value is NOT the same as `middlePosition` from the UI Component convention. A `SkewFactor` of 0.3 and a `middlePosition` of 1000 produce different curves even for the same min/max range.
