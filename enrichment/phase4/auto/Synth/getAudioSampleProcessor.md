Returns a `ScriptAudioSampleProcessor` handle to the processor with the given name that holds audio file data. Processors that expose audio file data include `AudioLooper`, `ConvolutionReverb`, and scriptnode containers with audio file nodes.

> [!Warning:$WARNING_TO_BE_REPLACED$] If a processor with the given name exists but has no audio file data, it is silently skipped. The error message reports the processor as "not found" rather than indicating a type mismatch.
