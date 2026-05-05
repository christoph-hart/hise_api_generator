## setTablePoint

**Examples:**


Edge points (index 0 and the last index) ignore the `x` parameter -- only `y` and `curve` are applied. The x values 0 and 1.0 shown above are conventional but have no effect on edge points.


**Pitfalls:**
- The `curve` parameter controls interpolation curvature between this point and the next: `0.5` = linear, values below 0.5 = concave (faster initial change), values above 0.5 = convex (slower initial change). This is not documented in the method signature and can only be understood through experimentation or by examining real-world usage patterns.
