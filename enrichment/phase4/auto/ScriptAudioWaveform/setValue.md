Sets the component's value. Thread-safe - can be called from any thread, and the UI update happens asynchronously.

> **Warning:** If called during `onInit`, the value is not restored after recompilation.