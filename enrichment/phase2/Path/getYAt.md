## getYAt

**Examples:**


**Pitfalls:**
- `getYAt` operates in whatever coordinate space the path currently occupies. If the path was built in normalized [0, 1] space, call `scaleToFit` first to transform it to pixel coordinates before querying with pixel X positions. Querying a normalized path with pixel-space X values returns `undefined` because the X is outside the path's horizontal extent.
