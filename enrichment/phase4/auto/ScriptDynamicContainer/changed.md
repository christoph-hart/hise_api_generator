Triggers the container's control callback (either the custom one set via `setControlCallback()` or the default `onControl` handler) for the container's own value. This fires the container-level callback, not the dynamic child value callbacks.

> [!Warning:$WARNING_TO_BE_REPLACED$] Cannot be called during onInit - logs a console message and returns without executing.
