## getBounds

**Examples:**


The `scaleFactor` parameter of `getBounds` is a uniform multiplier applied to the path coordinates before computing bounds. Passing the component's pixel width when the path was built in unit coordinates produces bounds in pixel space, which can then be passed directly to `drawPath` or `fillPath`.
