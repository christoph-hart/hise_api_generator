Loads an audio file from the pool using a pool reference string. Use `{PROJECT_FOLDER}` for files in the project's AudioFiles folder or `{EXP::expansionName}` for expansion content. When loading user-imported files from a `FileSystem.browse()` callback, pass `file.toString(0)` to get an absolute path rather than a pool wildcard.

> [!Warning:Load pool first in HISE IDE] In the HISE IDE, call `Engine.loadAudioFilesIntoPool()` before using `{PROJECT_FOLDER}` references. Exported plugins embed audio files automatically and do not need this step.
