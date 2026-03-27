Sets the specified property to the given value. Values are automatically clipped to the valid range for that property. Setting certain properties triggers cascading adjustments to maintain consistency - for example, changing `SampleStart` may adjust `LoopXFade`, `LoopStart`, and `SampleStartMod`.

> [!Warning:$WARNING_TO_BE_REPLACED$] When setting `LoVel` and `HiVel` on the same sample, auto-clipping can interfere. Setting `LoVel` above the current `HiVel` clamps it down. Set both values twice in succession to ensure both survive the interdependent range clamping.
