Adds a new control point at the given normalised coordinates with a default curve factor of 0.5 (linear). For building curves with multiple points, prefer `setTablePointsFromArray()` which sets all points in one call.

> [!Warning:$WARNING_TO_BE_REPLACED$] Each call triggers a full lookup table re-render. Calling `addTablePoint()` in a loop is significantly slower than a single `setTablePointsFromArray()` call with the complete point array.
