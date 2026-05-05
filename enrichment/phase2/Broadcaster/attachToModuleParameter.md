## attachToModuleParameter

**Examples:**


**Pitfalls:**
- The `moduleIds` parameter must be string IDs, not scripting object references. Passing a reference from `Synth.getEffect()` produces an error. Use the processor's string ID instead.
