# Pipeline Issues

Bugs, design issues, and silent failures discovered during C++ source analysis.
Sorted by severity (critical first).

**Types:** silent-fail, missing-validation, inconsistency, code-smell, ux-issue
**Severity:** critical, high, medium, low

---

## Critical

(No issues yet.)

## High

(No issues yet.)

## Medium

### TransportHandler.setOnTransportChange -- clearIf targets wrong callback slot

- **Type:** inconsistency
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~8452
- **Observed:** The sync branch of `setOnTransportChange` calls `clearIf(tempoChangeCallbackAsync, f)` instead of `clearIf(transportChangeCallbackAsync, f)`. This means registering a synchronous transport callback does not clear a previously registered async transport callback for the same function. It may also inadvertently clear an unrelated tempo async callback if it holds the same function reference.
- **Expected:** Should call `clearIf(transportChangeCallbackAsync, f)` to match the pattern used in all other `setOn*` methods.

### MidiList.setRange -- parameter name does not match loop behavior

- **Type:** inconsistency
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~155, ScriptingApiObjects.h:~296
- **Observed:** The loop `for (int i = startIndex; i < numToFill; i++)` uses the `numToFill` parameter as an absolute end bound, not as a count relative to `startIndex`. Calling `setRange(10, 5, 99)` fills zero slots because `10 < 5` is immediately false. The parameter name `numToFill` implies a relative count.
- **Recommended fix:** Rename the parameter from `numToFill` to `endIndex` (in both the header declaration and Doxygen comment) to match the actual loop behavior. No runtime change needed - the loop logic itself is fine, only the name is misleading. Update the Doxygen comment from "Sets a range of items to the same value" to something like "Sets slots from startIndex up to (but not including) endIndex to the same value."

### MidiList.restoreFromBase64String -- numValues counter not recalculated

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~170
- **Observed:** After `restoreFromBase64String()` overwrites the raw `int[128]` array via `MemoryBlock::fromBase64Encoding` + `memcpy`, the internal `numValues` counter is not recalculated. `isEmpty()` and `getNumSetValues()` return stale values from before the restore until the next `setValue()` call forces a recount.
- **Expected:** Recalculate `numValues` by scanning the array after restoring, or call the existing recount logic that `setValue()` triggers.

## Low

### MidiList.setValue -- Doxygen comment claims value range -127 to 128

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptingApiObjects.h:~290
- **Observed:** The Doxygen comment on `setValue` says the value parameter should be "between -127 and 128", but the C++ implementation stores values as plain integers with no clamping or validation. Any `int` value works.
- **Expected:** Either add range clamping to match the documentation, or correct the Doxygen comment to reflect that values are unclamped integers.
