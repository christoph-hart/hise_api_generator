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

## Low

(No issues yet.)
