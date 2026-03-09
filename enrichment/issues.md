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

### UserPresetHandler.setUseCustomUserPresetModel -- silently ignores non-function callbacks

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptExpansion.cpp:~250
- **Observed:** If either `loadCallback` or `saveCallback` is not a valid JavaScript function, the method silently returns without enabling the custom data model or reporting any error. The user has no indication that the call had no effect. Subsequent calls to `setCustomAutomation` then fail with the confusing error "you need to enable setUseCustomDataModel() before calling this method", which does not hint at the actual cause (invalid callback arguments).
- **Expected:** Report a script error when either callback is not a function, e.g., "loadCallback must be a function" or "saveCallback must be a function".

### UserPresetHandler.updateAutomationValues -- IndexSorter uses first["id"] for both comparands

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptExpansion.cpp:~591
- **Observed:** In the `IndexSorter::compareElements` method, both `i1` and `i2` are constructed from `first["id"].toString()` instead of `i2` using `second["id"].toString()`. This causes the comparator to always return 0 (equal), effectively disabling the index-based sort. Values are applied in the order they appear in the input array rather than sorted by automation index.
- **Expected:** Line 591 should read `Identifier i2(second["id"].toString());` instead of `Identifier i2(first["id"].toString());`.

### UserPresetHandler.updateAutomationValues -- undo path does not capture old values for array input

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptExpansion.cpp:~472-523
- **Observed:** The `AutomationValueUndoAction` constructor captures old values via `newData.getDynamicObject()`, which returns null when `newData` is an Array (the only valid non-integer input format). The `oldData` member remains uninitialized (`undefined`). When `undo()` calls `updateAutomationValues(oldData, ...)`, the undefined value is neither an int, DynamicObject, nor Array, so the method silently does nothing. `Engine.undo()` after an undoable `updateAutomationValues` call with array data has no effect.
- **Expected:** The undo action constructor should iterate the array of `{"id", "value"}` objects and capture old values in the same array format, or the method should convert array input to DynamicObject format before creating the undo action.

### UserPresetHandler.setParameterGestureCallback -- numExpectedArgs mismatch (2 vs 3)

- **Type:** inconsistency
- **Severity:** medium
- **Location:** ScriptExpansion.cpp:~74 (constructor), ScriptExpansion.cpp:~435 (setter), ScriptExpansion.cpp:~165 (invocation)
- **Observed:** The `parameterGestureCallback` WeakCallbackHolder is initialized with `numExpectedArgs=2` in the constructor (line 74) and re-created with 2 in `setParameterGestureCallback` (line 435). The parse-time diagnostic (`ADD_CALLBACK_DIAGNOSTIC` at line 105) also checks for 2 arguments. However, `onParameterGesture` (line 154) passes 3 arguments (type, slotIndex, startGesture) via `callSync(NativeFunctionArgs)`. Users following the diagnostic guidance write 2-parameter callbacks and silently miss the `startGesture` boolean.
- **Expected:** Change `numExpectedArgs` to 3 in both the constructor initializer and `setParameterGestureCallback`, so the diagnostic correctly reports that the callback expects 3 arguments.

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

### MidiAutomationHandler.setAutomationDataFromObject -- silently clears all automation on non-Array input

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~10093
- **Observed:** If `automationData` is not an Array (e.g., a single object, number, or string), `ValueTreeConverters::convertVarArrayToFlatValueTree` produces an empty ValueTree. `restoreFromValueTree` then clears all existing automation entries and adds nothing. The user's automation data is silently wiped with no error.
- **Expected:** Validate that `automationData` is an Array before proceeding, and report a script error if not, e.g., "automationData must be an Array".

### MacroHandler.setMacroDataFromObject -- silently ignores non-Array input

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~9841
- **Observed:** If `jsonData` is not an Array, the method silently returns without modifying any macro connections or firing the update callback. No error is reported.
- **Expected:** Report a script error when `jsonData` is not an Array, e.g., "jsonData must be an Array".

### MidiAutomationHandler.setUpdateCallback -- silently ignores non-function argument

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~10098
- **Observed:** If the argument is not a valid JavaScript function, the method silently returns without modifying or clearing the callback. No error is reported.
- **Expected:** Report a script error when the callback argument is not a function, e.g., "callback must be a function".

### MidiAutomationHandler.setUpdateCallback -- no way to clear the callback

- **Type:** ux-issue
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~10096-10111
- **Observed:** There is no mechanism to unregister the update callback. Passing a non-function value is silently ignored (see above), so the previous callback remains active. The callback persists until the MidiAutomationHandler object is garbage collected.
- **Expected:** Either accept `false` to clear the callback, or provide a separate `clearUpdateCallback()` method.

### MacroHandler.setUpdateCallback -- silently ignores non-function argument

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~9862
- **Observed:** If the argument is not a valid JavaScript function, the method silently returns without modifying or clearing the callback. No error is reported.
- **Expected:** Report a script error when the callback argument is not a function, e.g., "callback must be a function".

### MacroHandler.setUpdateCallback -- no way to clear the callback

- **Type:** ux-issue
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~9860-9871
- **Observed:** There is no mechanism to unregister the update callback. Passing a non-function value is silently ignored (see above), so the previous callback remains active. The callback persists until the MacroHandler object is garbage collected.
- **Expected:** Either accept `false`/`undefined` to clear the callback, or provide a separate `clearUpdateCallback()` method.

### MacroHandler.getMacroDataObject -- getCallbackArg iterates all parameters, overwrites range on single object

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~10032-10055
- **Observed:** `getCallbackArg(macroIndex, p, parameterIndex, wasAdded)` receives a specific `parameterIndex` but then loops over ALL parameters in the macro slot (`md->getNumParameters()`). Each loop iteration overwrites the range properties (`FullStart`, `FullEnd`, `Start`, `End`, `Interval`, `Skew`, `Inverted`) and potentially the `Attribute` and `CustomAutomation` properties on the same DynamicObject. When a macro slot has multiple connected parameters, each returned object contains the range data of the LAST parameter in the slot rather than the specific parameter it represents. The `parameterIndex` argument is only used to set the initial `Attribute` at line 10026 but gets overwritten if any parameter is a custom automation.
- **Expected:** The loop should either be removed (just look up the specific parameter by `parameterIndex`) or the function should build range data from only the parameter matching `parameterIndex`.

### Message.getPolyAfterTouchNoteNumber -- accesses mutable pointer in const getter

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~768
- **Observed:** `getPolyAfterTouchNoteNumber()` is a const getter but accesses `messageHolder->getAfterTouchNumber()` (the mutable pointer) instead of `constMessageHolder->getAfterTouchNumber()`. In read-only contexts (e.g., voice start modulators), `constMessageHolder` is set but `messageHolder` is null. The null check on `constMessageHolder` passes, then the method dereferences the null `messageHolder`, causing undefined behavior.
- **Expected:** Should access `constMessageHolder->getAfterTouchNumber()` instead of `messageHolder->getAfterTouchNumber()`.

### Message.getPolyAfterTouchPressureValue -- accesses mutable pointer in const getter

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~781
- **Observed:** Same root cause as `getPolyAfterTouchNoteNumber`. `getPolyAfterTouchPressureValue()` is a const getter but accesses `messageHolder->getAfterTouchValue()` instead of `constMessageHolder->getAfterTouchValue()`. Dereferences null pointer in read-only contexts.
- **Expected:** Should access `constMessageHolder->getAfterTouchValue()` instead of `messageHolder->getAfterTouchValue()`.

### Message.getProgramChangeNumber -- wrong pointer check and wrong error message

- **Type:** inconsistency
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~648
- **Observed:** The null-pointer guard checks `messageHolder` (mutable pointer) instead of `constMessageHolder`, and the error message says `"setVelocity()"` instead of `"getProgramChangeNumber()"`. This means the method incorrectly fails in read-only contexts where `constMessageHolder` is set but `messageHolder` is null, and produces a misleading error message.
- **Expected:** Should check `constMessageHolder == nullptr` and report `"getProgramChangeNumber()"` in the error message.

### Message.setStartOffset -- null check on wrong pointer

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~985
- **Observed:** The `ENABLE_SCRIPTING_SAFE_CHECKS` guard checks `constMessageHolder == nullptr` for the null check, but the actual write on line 996 uses `messageHolder->setStartOffset(...)`. In read-only contexts (voice start modulators), `constMessageHolder` is non-null but `messageHolder` is null. The null check passes, then the write dereferences null `messageHolder`.
- **Expected:** Should check `messageHolder == nullptr` (the mutable pointer) to match the write target, consistent with all other setter methods (setNoteNumber, setVelocity, setChannel, etc.).

### Message.sendToMidiOut -- missing null-pointer guard on messageHolder

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~1105-1121
- **Observed:** `sendToMidiOut()` has no `ENABLE_SCRIPTING_SAFE_CHECKS` guard around `messageHolder`. When called outside a mutable callback context, `makeArtificial()` silently returns 0 (since `makeArtificialInternal` checks `if (messageHolder != nullptr)`), but the next line `getScriptProcessor()->getMainController_()->sendToMidiOut(*messageHolder)` dereferences the null `messageHolder` pointer, causing undefined behavior (crash).
- **Expected:** Add a null-pointer check on `messageHolder` at the top of `sendToMidiOut()` with `reportIllegalCall("sendToMidiOut()", "midi event")`, matching the pattern used by other mutable-context methods like `ignoreEvent()`.

### Message.setStartOffset -- error message off by one

- **Type:** inconsistency
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~985
- **Observed:** The error message says "Max start offset is 65536 (2^16)" but the check `newStartOffset > UINT16_MAX` correctly accepts 65535 and rejects 65536. The actual maximum accepted value is 65535 (UINT16_MAX), not 65536 as the message states.
- **Expected:** Change the error message to "Max start offset is 65535 (UINT16_MAX)" or "Max start offset is 65535 (2^16 - 1)".

### Message.store -- silently ignores invalid MessageHolder argument

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~1062
- **Observed:** If the argument is not a valid MessageHolder object, `dynamic_cast<ScriptingObjects::ScriptingMessageHolder*>` returns null and the method silently does nothing. No error is reported. The user has no indication that the store operation failed.
- **Expected:** Report a script error when the argument is not a MessageHolder, e.g., "store() expects a MessageHolder object created by Engine.createMessageHolder()".

### MessageHolder.addToTimestamp -- int16 truncation silently corrupts delta values

- **Type:** silent-fail
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp:~5654
- **Observed:** The MessageHolder wrapper casts the `deltaSamples` parameter to `int16` before passing to `HiseEvent::addToTimeStamp(int)`. Values outside -32768..32767 silently overflow. For example, passing 50000 wraps to -15536, shifting the timestamp backward instead of forward. No error or warning is produced.
- **Expected:** Either accept the full `int` range (matching the underlying `HiseEvent::addToTimeStamp(int)` signature which takes an `int`), or validate the range and report a script error when the delta exceeds the int16 range.

### Date.ISO8601ToMilliseconds -- silently returns 0 for invalid ISO-8601 strings

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApi.cpp:~3770
- **Observed:** If an invalid or unparseable string is passed, `juce::Time::fromISO8601` returns a default-constructed Time (epoch = 0). The method returns 0, which is indistinguishable from a genuinely parsed Unix epoch timestamp. No error or warning is reported.
- **Expected:** Validate the input string before parsing, or check if the result is the default Time when the input is not an empty string, and report a script error for unparseable input.

## Low

### MessageHolder.addToTimestamp -- method not registered in constructor

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptingApiObjects.cpp:~5522-5580
- **Observed:** `addToTimestamp` is declared in the header (line 1592), implemented in the .cpp (line 5654), and listed in the Doxygen-generated base JSON, but is NOT registered via `ADD_API_METHOD_1` or `ADD_TYPED_API_METHOD_1` in the constructor, and is NOT in the Wrapper struct. The method is inaccessible from HISEScript despite appearing in the API documentation.
- **Expected:** Add `API_VOID_METHOD_WRAPPER_1(ScriptingMessageHolder, addToTimestamp);` to the Wrapper struct and `ADD_TYPED_API_METHOD_1(addToTimestamp, VarTypeChecker::Number);` (or `ADD_API_METHOD_1(addToTimestamp);`) to the constructor, consistent with the other timestamp methods.

### UserPresetHandler.setPostSaveCallback -- addAsSource debug label says "postCallback" instead of "postSaveCallback"

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptExpansion.cpp:~223
- **Observed:** `setPostSaveCallback` calls `postSaveCallback.addAsSource(this, "postCallback")` using the string `"postCallback"` as the debug source name. This is a copy-paste from the `setPostCallback` implementation above it. Both the post-load callback and the post-save callback share the same debug label.
- **Expected:** Should use `postSaveCallback.addAsSource(this, "postSaveCallback")` so the debug information system distinguishes the two callbacks in the HISE IDE.

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

### MessageHolder.setStartOffset -- no corresponding getStartOffset() method

- **Type:** ux-issue
- **Severity:** low
- **Location:** ScriptingApiObjects.cpp:~5649
- **Observed:** `setStartOffset()` writes the start offset to the HiseEvent, but there is no `getStartOffset()` method on MessageHolder. The value is write-only from the scripting API. Users cannot read back the start offset they set, nor inspect start offsets on events returned by `MidiPlayer.getEventList()` or captured via `Message.store()`.
- **Expected:** Add a `getStartOffset()` method that returns `(int)e.getStartOffset()`, consistent with the getter/setter pattern used by all other HiseEvent fields exposed on MessageHolder.

### Broadcaster.setBypassed -- async parameter name is inverted relative to behavior

- **Type:** inconsistency
- **Severity:** low
- **Location:** ScriptBroadcaster.cpp:~4466
- **Observed:** The third parameter of `setBypassed` is named `async`, but its value is passed directly to `resendLastMessage(var sync)`. The `ApiHelpers::isSynchronous()` boolean fallback interprets `true` as synchronous and `false` as asynchronous. So passing `async = true` actually produces synchronous dispatch, and `async = false` produces asynchronous dispatch -- the opposite of what the parameter name implies.
- **Expected:** Either rename the parameter to `sync` (matching `resendLastMessage`'s semantics), or negate the value before passing it to `resendLastMessage`. Using `SyncNotification`/`AsyncNotification` constants bypasses the boolean ambiguity but the parameter name still misleads users who pass booleans.
