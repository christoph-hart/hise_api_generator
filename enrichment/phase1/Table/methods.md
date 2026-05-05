# Table -- Method Documentation

## addTablePoint

**Signature:** `void addTablePoint(double x, double y)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires SimpleReadWriteLock::ScopedWriteLock on graphPoints, then calls fillLookUpTable() which allocates a HeapBlock and creates a JUCE Path.
**Minimal Example:** `{obj}.addTablePoint(0.5, 0.8);`

**Description:**
Adds a new control point to the table at the given normalized coordinates. The curve factor for the new point defaults to 0.5 (linear). After adding, the 512-element lookup table is re-rendered and a ContentChange notification is sent asynchronously. All coordinate values are used as-is -- no clamping is applied at the add stage (clamping happens during lookup table rendering via the Path). For bulk point setup, prefer `setTablePointsFromArray()` which renders the lookup table only once.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| x | Number | no | Normalized horizontal position of the new point | 0.0--1.0 |
| y | Number | no | Normalized vertical value at this point | 0.0--1.0 |

**Pitfalls:**
- Calling `addTablePoint()` in a loop triggers a full lookup table re-render (512 floats via PathFlatteningIterator) on every call. Use `setTablePointsFromArray()` for bulk setup.

**Cross References:**
- `$API.Table.setTablePointsFromArray$` -- bulk alternative that renders once
- `$API.Table.setTablePoint$` -- modify an existing point by index
- `$API.Table.getTablePointsAsArray$` -- retrieve current points

## getCurrentlyDisplayedIndex

**Signature:** `float getCurrentlyDisplayedIndex()`
**Return Type:** `Double`
**Call Scope:** safe
**Minimal Example:** `var pos = {obj}.getCurrentlyDisplayedIndex();`

**Description:**
Returns the last ruler position that was sent to the table's display updater, as a normalized value between 0.0 and 1.0. This position is updated whenever `getTableValueNormalised()` is called (which sends a display index notification as a side effect) or when a module queries the table during audio processing. Useful for reading back which position was last evaluated, typically for custom UI display synchronization.

**Parameters:**
None.

**Cross References:**
- `$API.Table.getTableValueNormalised$` -- querying a value also updates the displayed index
- `$API.Table.setDisplayCallback$` -- fires when the displayed index changes

## getTablePointsAsArray

**Signature:** `var getTablePointsAsArray()`
**Return Type:** `Array`
**Call Scope:** warning
**Call Scope Note:** Acquires SimpleReadWriteLock::ScopedReadLock and iterates all graph points to build the return array. Lock-free but O(n) with heap allocation for the array construction.
**Minimal Example:** `var points = {obj}.getTablePointsAsArray();`

**Description:**
Returns all table control points as a nested array. Each element is a 3-element sub-array `[x, y, curve]` where all values are normalized floats (0.0--1.0). The returned array is a snapshot -- modifying it does not affect the table. The points are returned in their stored order (sorted by x coordinate after any prior modification).

**Parameters:**
None.

**Cross References:**
- `$API.Table.setTablePointsFromArray$` -- inverse operation: set points from an array in the same format
- `$API.Table.setTablePoint$` -- modify a single point by index

**Example:**


## getTableValueNormalised

**Signature:** `float getTableValueNormalised(double normalisedInput)`
**Return Type:** `Double`
**Call Scope:** warning
**Call Scope Note:** Reads from the internal 512-float lookup array (lock-free), but sends a display index notification as a side effect which involves async notification dispatch.
**Minimal Example:** `var val = {obj}.getTableValueNormalised(0.5);`

**Description:**
Returns the interpolated output value of the table at the given normalized input position (0.0--1.0). The input is mapped to the internal 512-element lookup array using linear interpolation between adjacent entries. As a side effect, this call sends a display index notification that updates the ruler position shown in any connected ScriptTable UI component and fires the display callback if one is registered. If the input exceeds 1.0, the last table value is returned.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| normalisedInput | Number | no | Normalized input position to query | 0.0--1.0 |

**Pitfalls:**
- Calling this method updates the display ruler position and fires the display callback. This is intentional but may be unexpected if you only want a value lookup without visual side effects.

**Cross References:**
- `$API.Table.getCurrentlyDisplayedIndex$` -- reads back the position last set by this method
- `$API.Table.setDisplayCallback$` -- callback fired as a side effect of this method

**Example:**


## linkTo

**Signature:** `void linkTo(var otherTable)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Unregisters/re-registers event listeners and calls ExternalDataHolder::linkTo which may involve lock acquisition and data swapping.
**Minimal Example:** `{obj}.linkTo(otherTableData);`

**Description:**
Makes this Table handle refer to the same underlying data as another Table object. After linking, both handles share the same graph points and lookup table -- modifications through either handle affect both. The method validates that the other object is a compatible complex data reference of the same type (Table). Linking unregisters this handle from its previous data object's event listener and re-registers on the new shared data. Callbacks (display and content) registered on this handle continue to work and will fire based on the linked data's events.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| otherTable | ScriptObject | no | Another Table data object to link to | Must be a Table instance |

**Pitfalls:**
- Linking is one-directional at the handle level: this handle starts pointing to the other's data, but the other handle is unaffected. Both handles then share the same underlying data, so modifications through either are visible to both.

**Cross References:**
- `$API.Table.setContentCallback$` -- content callbacks remain active after linking and fire on the linked data
- `$API.Table.setDisplayCallback$` -- display callbacks remain active after linking
- `$API.Table.reset$` -- resets table to default linear ramp; linkTo changes data identity while reset changes data content

**Example:**


## reset

**Signature:** `void reset()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires SimpleReadWriteLock::ScopedWriteLock, clears the graphPoints array (heap deallocation), rebuilds the lookup table (HeapBlock allocation + Path construction).
**Minimal Example:** `{obj}.reset();`

**Description:**
Resets the table to its default state: two control points at (0, 0, 0.5) and (1, 1, 0.5), producing a linear ramp from 0 to 1. All existing points are removed. A ContentChange notification is sent asynchronously with point index -1 (indicating a bulk change), which fires any registered content callback.

**Parameters:**
None.

**Cross References:**
- `$API.Table.setTablePointsFromArray$` -- alternative for setting a specific curve; reset restores the default linear ramp
- `$API.Table.setContentCallback$` -- fires with index -1 after reset
- `$API.Table.linkTo$` -- changes data identity (points to different data); reset changes data content (restores default curve)

## setContentCallback

**Signature:** `void setContentCallback(var contentFunction)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Creates a WeakCallbackHolder (heap allocation), increments ref count, registers as source.
**Minimal Example:** `{obj}.setContentCallback(onTableChanged);`

**Description:**
Registers a callback function that fires whenever the table's content changes -- when points are added, removed, modified, or when the table is reset or bulk-updated via `setTablePointsFromArray()`. The callback receives a single argument: the index of the changed point, or -1 for bulk changes (reset, setTablePointsFromArray, setGraphPoints). Only one content callback can be active at a time; calling this again replaces the previous callback. Pass `false` to clear the callback.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| contentFunction | Function | yes | Callback to invoke on content changes | Must accept 1 argument |

**Callback Signature:** contentFunction(pointIndex: int)

**Pitfalls:**
- The pointIndex argument is -1 for bulk operations (reset, setTablePointsFromArray). Check for -1 before using it as an array index into getTablePointsAsArray().

**Cross References:**
- `$API.Table.setDisplayCallback$` -- fires on ruler position changes, not content changes
- `$API.Table.addTablePoint$` -- triggers this callback with the new point's index
- `$API.Table.setTablePoint$` -- triggers this callback with the modified point's index
- `$API.Table.setTablePointsFromArray$` -- triggers this callback with index -1 (bulk change)
- `$API.Table.reset$` -- triggers this callback with index -1

**Example:**


## setDisplayCallback

**Signature:** `void setDisplayCallback(var displayFunction)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Creates a WeakCallbackHolder (heap allocation), increments ref count, registers as source.
**Minimal Example:** `{obj}.setDisplayCallback(onDisplayChanged);`

**Description:**
Registers a callback function that fires whenever the table's ruler/display position changes. This happens when `getTableValueNormalised()` is called (which sends a display index notification as a side effect) or when a module queries the table during audio processing. The callback receives a single argument: the normalized position (0.0--1.0) that was last queried. Only one display callback can be active at a time; calling this again replaces the previous callback. Pass `false` to clear the callback.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| displayFunction | Function | yes | Callback to invoke when the ruler position changes | Must accept 1 argument |

**Callback Signature:** displayFunction(position: double)

**Cross References:**
- `$API.Table.setContentCallback$` -- fires on content changes, not ruler position changes
- `$API.Table.getTableValueNormalised$` -- triggers this callback as a side effect
- `$API.Table.getCurrentlyDisplayedIndex$` -- reads back the last position without triggering the callback

**Example:**


## setTablePoint

**Signature:** `void setTablePoint(int pointIndex, float x, float y, float curve)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires SimpleReadWriteLock::ScopedReadLock on graphPoints, then calls fillLookUpTable() which allocates a HeapBlock and creates a JUCE Path.
**Minimal Example:** `{obj}.setTablePoint(1, 0.5, 0.8, 0.3);`

**Description:**
Modifies an existing control point at the given index. All coordinate values (x, y, curve) are clamped to the 0.0--1.0 range via `jlimit`. For edge points (index 0 and the last point), the x position is preserved -- only y and curve are updated. For non-edge points, all three values are updated. After modification, the 512-element lookup table is re-rendered and a synchronous ContentChange notification is sent (unlike `addTablePoint` which uses async notification).

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| pointIndex | Number | no | Zero-based index of the point to modify | 0 to numPoints-1 |
| x | Number | no | New normalized horizontal position | 0.0--1.0 (ignored for edge points) |
| y | Number | no | New normalized vertical value | 0.0--1.0 |
| curve | Number | no | New curve factor | 0.0--1.0 (0.5 = linear) |

**Pitfalls:**
- Edge points (first and last) silently ignore the x parameter -- only y and curve are applied. No error is thrown when passing a different x value for an edge point.
- Each call triggers a full lookup table re-render. For modifying multiple points, consider using `setTablePointsFromArray()` which renders only once.

**Cross References:**
- `$API.Table.addTablePoint$` -- add a new point instead of modifying an existing one
- `$API.Table.setTablePointsFromArray$` -- bulk alternative for setting all points at once
- `$API.Table.getTablePointsAsArray$` -- retrieve current points to find indices

## setTablePointsFromArray

**Signature:** `void setTablePointsFromArray(var pointList)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires SimpleReadWriteLock::ScopedWriteLock, replaces all graph points, calls fillLookUpTable() which allocates a HeapBlock and creates a JUCE Path. Also performs Array iteration and validation.
**Minimal Example:** `{obj}.setTablePointsFromArray([[0.0, 0.0, 0.5], [0.5, 1.0, 0.3], [1.0, 0.5, 0.5]]);`

**Description:**
Replaces all table control points from a nested array. Each element must be a 3-element sub-array `[x, y, curve]` with normalized float values. The method validates that each sub-array has exactly 3 elements (script error otherwise) and requires at least 2 points (script error otherwise). All values are clamped to 0.0--1.0. The first point's x is forced to 0.0 and the last point's x is forced to 1.0 regardless of the values provided. After setting all points, the graph points are sorted by x, the lookup table is rendered once, and a ContentChange notification is sent. This is the preferred method for bulk point setup since it only triggers a single re-render.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| pointList | Array | no | Nested array of [x, y, curve] sub-arrays | Min 2 sub-arrays, each with exactly 3 elements |

**Pitfalls:**
- The first point's x is silently forced to 0.0 and the last point's x to 1.0. Passing different x values for edge points does not produce an error -- the values are overwritten.

**Cross References:**
- `$API.Table.getTablePointsAsArray$` -- inverse operation: retrieve points in the same format
- `$API.Table.addTablePoint$` -- add a single point; less efficient for bulk setup
- `$API.Table.setTablePoint$` -- modify a single existing point by index
- `$API.Table.reset$` -- shorthand for resetting to the default linear ramp

**Example:**

