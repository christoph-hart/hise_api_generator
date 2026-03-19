Returns the filename of the currently loaded user preset without the `.preset` extension or directory path. Returns an empty string if no preset has been loaded.

> **Warning:** Returns only the bare filename. If presets in different subdirectories share the same name, this method cannot distinguish between them. Use `Engine.getUserPresetList()` for full relative paths.