Sets the component's value. Thread-safe - can be called from any thread, and the UI update happens asynchronously.

> [!Warning:$WARNING_TO_BE_REPLACED$] If called during `onInit`, the value is not restored after recompilation.