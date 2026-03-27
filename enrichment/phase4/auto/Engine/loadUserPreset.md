Loads a user preset by relative path or ScriptFile object. The `.preset` extension is appended automatically. Relative paths are resolved against the UserPresets directory.

> [!Warning:$WARNING_TO_BE_REPLACED$] Cannot be called during `onInit` - a script error is thrown. Load presets from runtime callbacks (button handlers, timer callbacks) instead.