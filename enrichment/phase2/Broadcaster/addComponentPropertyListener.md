## addComponentPropertyListener

**Examples:**


**Pitfalls:**
- In the transform callback, the `targetIndex` is the index within the component array passed as the first parameter. When targeting a single component (not an array), `targetIndex` is always 0. Forgetting to account for this extra first parameter shifts all subsequent arguments.
