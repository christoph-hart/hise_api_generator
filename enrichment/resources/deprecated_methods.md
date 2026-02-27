# Deprecated Methods

Methods discovered during Phase 1 analysis that should use the
ADD_API_METHOD_N_DEPRECATED macro in their C++ constructor.

Format:

```
### ClassName.methodName(N)
Status: pending | applied
Reason: "suggestion text for the macro"

One-sentence rationale.
```

- N = argument count (maps to ADD_API_METHOD_N_DEPRECATED).
- Reason = exact string that goes in the macro's text parameter.
- Status: applied = macro already in C++. pending = waiting to be added.
- New entries are added here as they are discovered during Phase 1 class
  enrichment. Do not run separate sweeps -- discovery is a side effect of
  the per-class C++ analysis.

---

### Graphics.drawText(2)
Status: applied
Reason: "use drawAlignedText for better placement"

Superseded by drawAlignedText which supports alignment options.
