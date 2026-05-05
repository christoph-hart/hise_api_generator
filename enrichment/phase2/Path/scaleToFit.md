## scaleToFit

**Examples:**


**Pitfalls:**
- After calling `scaleToFit`, the path coordinates are permanently transformed. If you need to query positions on the path (e.g., with `getYAt`) in pixel space, call `scaleToFit` first, then query. The path cannot be "unscaled" back to its original coordinates - rebuild it if you need the original space.
