Sets the component's value. Thread-safe - can be called from any callback, and the UI updates asynchronously. The value propagates to any components connected via the `linkedTo` property.

> [!Warning:$WARNING_TO_BE_REPLACED$] If called during `onInit`, the value will not be restored after recompilation.
