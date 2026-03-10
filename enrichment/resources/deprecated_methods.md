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

### Broadcaster.sendMessage(2)
Status: pending
Reason: "use sendSyncMessage or sendAsyncMessage instead"

The second parameter (`isSync` bool) is ambiguous and hard to guess. The C++ implementation already emits a `debugError` at runtime but does not use the `ADD_API_METHOD_N_DEPRECATED` macro.

### Synth.noteOff(1)
Status: pending
Reason: "use noteOffByEventId instead"

Note-off by note number is unreliable with overlapping voices on the same pitch. The implementation calls `addNoteOff` then `reportScriptError` under `ENABLE_SCRIPTING_SAFE_CHECKS`, but does not use the `ADD_API_METHOD_N_DEPRECATED` macro. Also, the error message has a typo: "noteOfByEventId" instead of "noteOffByEventId".

### Synth.setUseUniformVoiceHandler(2)
Status: pending
Reason: "global envelopes are now automatic, remove this call"

Fully deprecated. The implementation immediately calls `reportScriptError("This function is deprecated. Just remove that call and enjoy global envelopes...")` and performs no work. Does not use the `ADD_API_METHOD_N_DEPRECATED` macro.
