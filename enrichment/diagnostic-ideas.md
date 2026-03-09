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

### Broadcaster.refreshContextMenuState -- no-op without prior attachToContextMenu

- **Category:** timeline-dependency
- **Priority:** low
- **Methods involved:** refreshContextMenuState, attachToContextMenu
- **Rationale:** `refreshContextMenuState` silently does nothing if `attachToContextMenu` has not been called first. A parse-time check could warn when `refreshContextMenuState` is called on a broadcaster that was never seen to have `attachToContextMenu` called.
- **Sketch:** Track broadcasters that have `attachToContextMenu` called in the same scope. When `refreshContextMenuState` is called, check whether the broadcaster variable was previously seen with `attachToContextMenu`. Emit a warning if not.

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
