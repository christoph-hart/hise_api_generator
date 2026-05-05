## addTablePoint

**Examples:**


The default table after `reset()` has two points (index 0 at x=0 and index 1 at x=1). Each `addTablePoint` appends after those, so the final point indices are 0-5. The last `setTablePoint` ensures the endpoint at x=1.0 has the correct y value.


For a simple 2-layer crossfade, no interior points are needed -- the curve parameter on the edge points creates the equal-power shape.


**Pitfalls:**
- The `reset()` -> `addTablePoint()` -> `setTablePoint()` sequence is order-dependent. Point indices shift as points are added, so always add all interior points before adjusting them with `setTablePoint()`. Adding a point between two `setTablePoint()` calls changes the indices of subsequent points.
