# MidiList -- Methods

## clear

**Signature:** `void clear()`
**Return Type:** `void`
**Call Scope:** safe

**Description:**
Resets all 128 slots to the sentinel value `-1` and sets the internal count of non-empty values to zero. Internally delegates to `fill(-1)`.

**Parameters:**

None.

**Cross References:**
- `$API.MidiList.fill$`
- `$API.MidiList.isEmpty$`

**Example:**


## fill

**Signature:** `void fill(int valueToFill)`
**Return Type:** `void`
**Call Scope:** safe

**Description:**
Sets all 128 slots to `valueToFill`. The internal non-empty counter is set to 128 if the value is anything other than `-1`, or 0 if the value is `-1`. This is the fastest way to initialize or reset a MidiList to a uniform value.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| valueToFill | int | Number | The value to write into every slot. | -- |

**Cross References:**
- `$API.MidiList.clear$`
- `$API.MidiList.setRange$`

**Example:**


## getValue

**Signature:** `int getValue(int index)`
**Return Type:** `int`
**Call Scope:** safe

**Description:**
Returns the value stored at the given index. If the index is out of range (negative or >= 128), returns `-1` without error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| index | int | no | Zero-based index (0-127). | -- |

**Cross References:**
- `$API.MidiList.setValue$`

**Example:**


## getValueAmount

**Signature:** `int getValueAmount(int valueToCheck)`
**Return Type:** `int`
**Call Scope:** safe

**Description:**
Counts how many of the 128 slots contain the specified value. When the list is empty (all `-1`), returns 128 if `valueToCheck` is `-1`, otherwise 0 - an optimized fast path that avoids scanning the array.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| valueToCheck | int | no | The value to count occurrences of. | -- |

**Cross References:**
- `$API.MidiList.getIndex$`
- `$API.MidiList.getNumSetValues$`

**Example:**


## getIndex

**Signature:** `int getIndex(int value)`
**Return Type:** `int`
**Call Scope:** safe

**Description:**
Returns the index of the first slot that contains the specified value, scanning from index 0 upward. Returns `-1` if the value is not found or if the list is empty. This is the MidiList equivalent of `Array.indexOf()`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| value | int | Number | The value to search for. | -- |

**Cross References:**
- `$API.MidiList.getValueAmount$`

**Example:**


## isEmpty

**Signature:** `bool isEmpty()`
**Return Type:** `bool`
**Call Scope:** safe

**Description:**
Returns `true` if all 128 slots contain the sentinel value `-1` (i.e., `numValues == 0`). This is an O(1) check against the internal counter, not a scan of the array.

**Parameters:**

None.

**Cross References:**
- `$API.MidiList.clear$`
- `$API.MidiList.getNumSetValues$`

**Example:**


## getNumSetValues

**Signature:** `int getNumSetValues()`
**Return Type:** `int`
**Call Scope:** safe

**Description:**
Returns the number of slots that contain a value other than `-1`. This is an O(1) read of the internal counter, not a scan.

**Parameters:**

None.

**Cross References:**
- `$API.MidiList.isEmpty$`
- `$API.MidiList.getValueAmount$`

**Example:**


## setValue

**Signature:** `void setValue(int index, int value)`
**Return Type:** `void`
**Call Scope:** safe

**Description:**
Sets the value at the given index. If the index is out of range (negative or >= 128), the call is silently ignored. The internal non-empty counter is updated branchlessly: it increments when a `-1` slot receives a non-`-1` value, and decrements when a non-`-1` slot is set to `-1`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| index | int | no | Zero-based index (0-127). Out-of-range values are ignored. | -- |
| value | int | no | The value to store. `-1` marks the slot as empty. | -- |

**Pitfalls:**
- [BUG] Despite the Doxygen comment ("between -127 and 128"), values are stored as plain integers with no clamping. Any `int` value can be stored.
- Out-of-range index access is silent - no error is reported.

**Cross References:**
- `$API.MidiList.getValue$`
- `$API.MidiList.setRange$`

**Example:**


## setRange

**Signature:** `void setRange(int startIndex, int numToFill, int value)`
**Return Type:** `void`
**Call Scope:** safe

**Description:**
Sets a contiguous range of slots to the same value. The start index is clamped to `[0, 127]` and `numToFill` is clamped to `min(numToFill, 127 - startIndex)`. **Important:** Due to the internal loop using `numToFill` as an absolute end bound (`for i = startIndex; i < numToFill`), the method only works correctly when `startIndex` is 0 or when `numToFill > startIndex`. When `startIndex >= numToFill`, no slots are modified.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| startIndex | int | no | First index to fill (clamped to 0-127). | -- |
| numToFill | int | no | End bound for the fill loop. Effectively sets indices from `startIndex` up to (but not including) `numToFill`. | -- |
| value | int | no | The value to write. | -- |

**Pitfalls:**
- [BUG] The `numToFill` parameter is used as an absolute end index in the loop, not as a count relative to `startIndex`. Calling `setRange(10, 5, 99)` fills zero slots because the loop condition `10 < 5` is immediately false.

**Cross References:**
- `$API.MidiList.fill$`
- `$API.MidiList.setValue$`

**Example:**


## getBase64String

**Signature:** `String getBase64String()`
**Return Type:** `String`
**Call Scope:** warning
**Call Scope Note:** String involvement, atomic ref-count operations

**Description:**
Serializes all 128 integer values into a Base64-encoded string. The encoding covers the raw `int[128]` memory (512 bytes), producing a deterministic string that can be stored in user presets, XML, or any text-based storage. Use `restoreFromBase64String()` to decode.

**Parameters:**

None.

**Cross References:**
- `$API.MidiList.restoreFromBase64String$`

**Example:**


## restoreFromBase64String

**Signature:** `void restoreFromBase64String(String base64encodedValues)`
**Return Type:** `void`
**Call Scope:** warning
**Call Scope Note:** String involvement, atomic ref-count operations

**Description:**
Restores all 128 values from a Base64-encoded string previously created by `getBase64String()`. The raw `int[128]` memory is overwritten directly. Note: the internal `numValues` counter is **not** recalculated after restoration, so `getNumSetValues()` and `isEmpty()` may return stale values.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| base64encodedValues | String | String | A Base64-encoded string produced by `getBase64String()`. | -- |

**Pitfalls:**
- [BUG] The `numValues` counter is not recalculated after `restoreFromBase64String()`. This means `isEmpty()` and `getNumSetValues()` may return incorrect values until you manually set or clear a value (which triggers a counter update).

**Cross References:**
- `$API.MidiList.getBase64String$`

**Example:**

