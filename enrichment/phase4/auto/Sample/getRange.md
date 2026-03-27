Returns a two-element array `[min, max]` with the valid value range for the specified property. This is essential for loop-related properties where ranges are interdependent - for example, `LoopEnd` cannot exceed `SampleEnd`, and `LoopXFade` depends on both `LoopStart` and `SampleStart`.

> [!Warning:$WARNING_TO_BE_REPLACED$] Ranges are dynamic. Re-query after any `set()` call that changes a related property - cached range values from an earlier call may be stale.
