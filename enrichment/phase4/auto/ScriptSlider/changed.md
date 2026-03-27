Forces the slider to fire its control callback and notify value listeners, even when the value was set programmatically. Use this after `setValue()` or `setValueNormalized()` when downstream logic depends on callback execution.

> [!Warning:$WARNING_TO_BE_REPLACED$] Do not call this in `onInit`; it is ignored there. If `deferControlCallback` is enabled, callback execution happens later, not immediately.
