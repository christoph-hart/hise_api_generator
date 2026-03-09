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

### TransportHandler.setEnableGrid -- error message says wrong range

- **Type:** inconsistency
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~8644
- **Observed:** The error message `"Illegal tempo value. Use 1-18"` implies index 0 is invalid, but the code accepts index 0 (Whole note) as a valid tempo factor. The `TempoSyncer::getTempoName(tempoFactor)` call succeeds for index 0.
- **Expected:** Change the error message to `"Illegal tempo value. Use 0-18"` to include the valid Whole note index.

### GlobalCable.connectToGlobalModulator -- silent failure when parent is not GlobalModulatorContainer

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~9613
- **Observed:** If the modulator is found by name but its parent is not a `GlobalModulatorContainer`, the method silently does nothing. The `dynamic_cast<GlobalModulatorContainer*>` fails and execution falls through without reporting an error or returning an indication of failure.
- **Expected:** Report a script error when the modulator exists but its parent is not a `GlobalModulatorContainer` (e.g., "Modulator 'X' must be inside a GlobalModulatorContainer").

## Low

### MidiList.setValue -- Doxygen comment claims value range -127 to 128

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptingApiObjects.h:~290
- **Observed:** The Doxygen comment on `setValue` says the value parameter should be "between -127 and 128", but the C++ implementation stores values as plain integers with no clamping or validation. Any `int` value works.
- **Expected:** Either add range clamping to match the documentation, or correct the Doxygen comment to reflect that values are unclamped integers.

### Broadcaster.attachToModuleParameter -- error message says "mouse events" instead of "module parameter events"

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptBroadcaster.cpp:~4018
- **Observed:** The error message when the broadcaster has the wrong argument count says `"If you want to attach a broadcaster to mouse events, it needs three parameters (processorId, parameterId, value)"`. The word "mouse events" is incorrect -- this method is for module parameter events. The error was likely copy-pasted from `attachToComponentMouseEvents`.
- **Expected:** Change the error message to `"If you want to attach a broadcaster to module parameter events, it needs three parameters (processorId, parameterId, value)"`.

### Broadcaster.attachToInterfaceSize -- error message says "visibility events" instead of "interface size events"

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptBroadcaster.cpp:~3930
- **Observed:** The error message when the broadcaster has the wrong argument count says `"If you want to attach a broadcaster to visibility events, it needs two parameters (width and height)"`. The word "visibility" is incorrect -- this method is for interface size events, not visibility events. The error was likely copy-pasted from `attachToComponentVisibility`.
- **Expected:** Change the error message to `"If you want to attach a broadcaster to interface size events, it needs two parameters (width and height)"`.

### Broadcaster.attachToSampleMap -- single-module error message says "routing matrix" instead of "samplers"

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptBroadcaster.cpp:~4270
- **Observed:** When a single (non-array) module ID is passed to `attachToSampleMap` and the module is not a `ModulatorSampler`, the error message says `"the modules must have a routing matrix"` instead of `"the modules must be samplers"`. The array branch at line 4260 uses the correct message. The single-module branch at line 4270 was likely copy-pasted from `attachToRoutingMatrix`.
- **Expected:** Change the error message in the single-module branch to `"the modules must be samplers"` to match the array branch.

### Broadcaster.setReplaceThisReference -- flag is stored but never read

- **Type:** code-smell
- **Severity:** low
- **Location:** ScriptBroadcaster.cpp:~4458, ScriptBroadcaster.h:~319
- **Observed:** `setReplaceThisReference` stores the boolean in the `replaceThisReference` member, but no code reads this member. `ScriptTarget::callSync` at line 898 unconditionally uses `var::NativeFunctionArgs(obj, args.getRawDataPointer(), args.size())`, always replacing `this` with the `obj` parameter from `addListener`. Calling `setReplaceThisReference(false)` is a no-op.
- **Expected:** Either read `replaceThisReference` in `ScriptTarget::callSync` (passing `var()` or the broadcaster as the thisObject when `false`), or remove the method and member if the feature is intentionally abandoned.

### Broadcaster.setBypassed -- async parameter name is inverted relative to behavior

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptBroadcaster.cpp:~4466
- **Observed:** The third parameter of `setBypassed` is named `async`, but its value is passed directly to `resendLastMessage(var sync)`. The `ApiHelpers::isSynchronous()` boolean fallback interprets `true` as synchronous and `false` as asynchronous. So passing `async = true` actually produces synchronous dispatch, and `async = false` produces asynchronous dispatch -- the opposite of what the parameter name implies.
- **Expected:** Either rename the parameter to `sync` (matching `resendLastMessage`'s semantics), or negate the value before passing it to `resendLastMessage`. Using `SyncNotification`/`AsyncNotification` constants bypasses the boolean ambiguity but the parameter name still misleads users who pass booleans.
