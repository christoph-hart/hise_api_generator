Triggers the control callback for this button, either the custom callback set via `setControlCallback()` or the default `onControl` handler. Use this after calling `setValue()` to notify the callback of the new value.

> [!Warning:$WARNING_TO_BE_REPLACED$] Cannot be called during `onInit` - if called during initialisation, it logs a console message and returns without executing.