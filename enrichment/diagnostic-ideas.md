# Diagnostic Ideas

Opportunities for `addDiagnostic()` query lambdas discovered during C++ source analysis.
These are not bugs -- the underlying HISE behavior is correct -- but users would benefit
from early LSP warnings that catch mistakes at parse time.

Sorted by priority (high first).

**Categories:** timeline-dependency, precondition, value-check, combination-check, state-validation
**Priority:** high, medium, low

---

## High

(No ideas yet.)

## Medium

### Broadcaster.attachToComplexData -- broadcaster arg count mismatch

- **Category:** precondition
- **Priority:** medium
- **Methods involved:** attachToComplexData, attachToComponentMouseEvents, attachToComponentProperties (and other attach methods with fixed arg count requirements)
- **Rationale:** Many Broadcaster attach methods require a specific number of arguments on the broadcaster (e.g., attachToComplexData requires 3, attachToComponentMouseEvents requires 2). A mismatch produces a runtime error but could be caught at parse time by checking the argument count of the `Engine.createBroadcaster()` call that created the broadcaster variable.
- **Sketch:** When an attach method call is encountered, trace the broadcaster variable back to its `Engine.createBroadcaster()` initializer, count the args array length or property count, and compare against the required count for the specific attach method. Emit a warning if they don't match.

## Low

### File.toReferenceString -- invalid folderType string

- **Category:** value-check
- **Priority:** low
- **Methods involved:** toReferenceString
- **Rationale:** The `folderType` parameter only accepts 12 specific strings (HISE subdirectory identifiers). An invalid string produces a runtime error "Illegal folder type" but could be caught at parse time. This is the same pattern as `Broadcaster.addComponentRefreshListener`.
- **Sketch:** When `toReferenceString` is called with a string literal, check it against the known set {"AudioFiles", "Images", "SampleMaps", "MidiFiles", "UserPresets", "Samples", "Scripts", "Binaries", "Presets", "XmlPresetBackups", "AdditionalSourceCode", "Documentation"}. Emit a warning if no match.

### Broadcaster.addComponentRefreshListener -- invalid refreshType string

- **Category:** value-check
- **Priority:** low
- **Methods involved:** addComponentRefreshListener
- **Rationale:** The refreshType parameter only accepts 5 specific strings. An invalid string produces a runtime error but could be caught at parse time by checking string literals passed to this parameter against the known valid set.
- **Sketch:** When addComponentRefreshListener is called with a string literal as the second argument, check it against {"repaint", "changed", "updateValueFromProcessorConnection", "loseFocus", "resetValueToDefault"}. Emit a warning if no match.

### Broadcaster.attachToComponentMouseEvents -- invalid callbackLevel string

- **Category:** value-check
- **Priority:** low
- **Methods involved:** attachToComponentMouseEvents
- **Rationale:** The callbackLevel parameter only accepts 6 specific strings. An invalid string produces a runtime error but could be caught at parse time.
- **Sketch:** When attachToComponentMouseEvents is called with a string literal as the second argument, check it against the known callback level strings. Emit a warning if no match.

### Broadcaster.attachToEqEvents -- invalid event type string

- **Category:** value-check
- **Priority:** low
- **Methods involved:** attachToEqEvents
- **Rationale:** The eventTypes parameter only accepts 4 specific strings ("BandAdded", "BandRemoved", "BandSelected", "FFTEnabled"). An invalid string produces a runtime error but could be caught at parse time by checking string literals.
- **Sketch:** When attachToEqEvents is called with a string literal or an array of string literals as the second argument, check each against the known event type set. Emit a warning if no match.

### Graphics.drawMarkdownText -- requires setTextBounds on MarkdownRenderer

- **Category:** timeline-dependency
- **Priority:** low
- **Methods involved:** drawMarkdownText, MarkdownRenderer.setTextBounds
- **Rationale:** `drawMarkdownText` requires `setTextBounds()` to have been called on the MarkdownRenderer object first. Without it, the method fails with a clear error message at runtime, but a parse-time check could catch this earlier by verifying that the MarkdownRenderer variable was seen with a `setTextBounds` call in the same scope.
- **Sketch:** When `drawMarkdownText` is called, trace the MarkdownRenderer variable back to its creation and check if `setTextBounds` was called on it before `drawMarkdownText`. Emit a warning if not.

### Graphics.beginBlendLayer -- invalid blend mode string silently fails

- **Category:** value-check
- **Priority:** low
- **Methods involved:** beginBlendLayer
- **Rationale:** `beginBlendLayer` silently fails when an invalid blend mode string is passed -- the layer is not created and no error is reported. A parse-time check could validate string literals against the 25 known blend mode values and warn about typos or unsupported modes.
- **Sketch:** When `beginBlendLayer` is called with a string literal as the first argument, check it against the known set {"Normal", "Lighten", "Darken", "Multiply", "Average", "Add", "Subtract", "Difference", "Negation", "Screen", "Exclusion", "Overlay", "SoftLight", "HardLight", "ColorDodge", "ColorBurn", "LinearDodge", "LinearBurn", "LinearLight", "VividLight", "PinLight", "HardMix", "Reflect", "Glow", "Phoenix"}. Emit a warning if no match.

### Broadcaster.refreshContextMenuState -- no-op without prior attachToContextMenu

- **Category:** timeline-dependency
- **Priority:** low
- **Methods involved:** refreshContextMenuState, attachToContextMenu
- **Rationale:** `refreshContextMenuState` silently does nothing if `attachToContextMenu` has not been called first. A parse-time check could warn when `refreshContextMenuState` is called on a broadcaster that was never seen to have `attachToContextMenu` called.
- **Sketch:** Track broadcasters that have `attachToContextMenu` called in the same scope. When `refreshContextMenuState` is called, check whether the broadcaster variable was previously seen with `attachToContextMenu`. Emit a warning if not.

### Synth.attachNote -- requires setFixNoteOnAfterNoteOff before use

- **Category:** timeline-dependency
- **Priority:** medium
- **Methods involved:** attachNote, setFixNoteOnAfterNoteOff
- **Rationale:** `attachNote` requires `setFixNoteOnAfterNoteOff(true)` to have been called first. Without it, a runtime script error is thrown: "You must call setFixNoteOnAfterNoteOff() before calling this method". A parse-time check could catch this by verifying that `setFixNoteOnAfterNoteOff` was called in the same script scope before any `attachNote` call.
- **Sketch:** When `attachNote` is encountered, scan the onInit scope (or the current script's preceding statements) for a `setFixNoteOnAfterNoteOff` call. Emit a warning if not found.

### Synth.setClockSpeed -- invalid clock speed value

- **Category:** value-check
- **Priority:** low
- **Methods involved:** setClockSpeed
- **Rationale:** `setClockSpeed` only accepts the values 0, 1, 2, 4, 8, 16, 32. Any other value produces a runtime error. A parse-time check could validate integer literals passed to this parameter against the known set and warn about invalid values like 3, 6, or 64.
- **Sketch:** When `setClockSpeed` is called with an integer literal, check it against {0, 1, 2, 4, 8, 16, 32}. Emit a warning if no match.

---

## Entry Template (do not delete)

```
### ClassName.methodName -- short description

- **Category:** timeline-dependency | precondition | value-check | combination-check | state-validation
- **Priority:** high | medium | low
- **Methods involved:** methodA, methodB
- **Rationale:** Why this diagnostic would be valuable for users.
- **Sketch:** Informal description of what the query lambda would check.
```
