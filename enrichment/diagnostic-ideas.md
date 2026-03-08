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

(No ideas yet.)

## Low

(No ideas yet.)

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
