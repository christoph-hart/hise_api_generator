Registers a callback that fires after a user preset has been saved. The callback receives a file reference to the saved preset. Use this to update the UI after a save - for example, refreshing a preset browser or showing a confirmation.

> [!Warning:$WARNING_TO_BE_REPLACED$] The callback argument is `undefined` when the preset was saved to a non-file target. Guard with `isDefined(presetFile)` before calling methods on it.
