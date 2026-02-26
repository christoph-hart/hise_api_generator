# Deprecated Methods

Methods listed here are considered deprecated. Phase 1 agents must mark
these as disabled with reason "deprecated" in the class methods.md file.

Format:

```
### ClassName.methodName()
Replacement: ClassName.replacementMethod()
Severity: Error | Warning | Information | Hint

One-sentence rationale. Brief enough for an LSP diagnostic message.
```

Rules:
- Use * as ClassName for methods deprecated across all inheriting classes.
- Replacement is required. Use `None` if the call should simply be removed.
- Severity uses LSP DiagnosticSeverity enum names:
  - Error: method throws reportScriptError at runtime
  - Warning: method logs a console warning or has a clearly better replacement
  - Information / Hint: method still works but there is a preferred alternative
- Rationale must be one sentence max. Explain *why* it is deprecated, not
  how to use the replacement.

New entries are added here as they are discovered during Phase 1 class
enrichment. Do not run separate sweeps -- discovery is a side effect of
the per-class C++ analysis.

---

### *.setColour()
Replacement: set("colourId", colourValue)
Severity: Warning

Uses magic number indices instead of named colour IDs.
