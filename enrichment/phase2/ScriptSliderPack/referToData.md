## referToData

**Examples:**


**Pitfalls:**
- If two packs share one data handle, programmatic writes in either pack affect both views immediately. Guard callback logic to avoid feedback loops.

**Cross References:**
- `Engine.createAndRegisterSliderPackData`
